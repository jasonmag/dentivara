class AppointmentScheduler
  SLOT_INTERVAL = 15.minutes
  ACTIVE_STATUSES = %w[pending confirmed checked_in in_progress completed].freeze

  attr_reader :date, :clinic_service, :duration_minutes, :preparation_minutes, :buffer_minutes, :preferred_user

  def initialize(date:, clinic_service: nil, duration_minutes: nil, preparation_minutes: nil, buffer_minutes: 10, preferred_user: nil)
    @date = date.to_date
    @clinic_service = clinic_service
    @duration_minutes = duration_minutes.presence || clinic_service&.duration_minutes || 30
    @preparation_minutes = preparation_minutes.presence || clinic_service&.preparation_minutes || 0
    @buffer_minutes = buffer_minutes.presence || 10
    @preferred_user = preferred_user
  end

  def available_dentists_for(starts_at)
    dentists = preferred_user.present? ? [ preferred_user ] : User.dentist.order(:name).to_a
    dentists.select { |dentist| dentist_available?(dentist, starts_at, ends_at_for(starts_at)) }
  end

  def first_available_dentist(starts_at)
    available_dentists_for(starts_at).first
  end

  def slots(limit: nil)
    return [] unless clinic_open?

    range_start, range_end = clinic_bounds
    return [] if range_end <= Time.current

    slot_start = [ range_start, next_bookable_slot_start ].max
    available_slots = []

    while slot_start + occupied_duration <= range_end
      dentists = available_dentists_for(slot_start)
      if dentists.any? && clinic_capacity_available?(slot_start, ends_at_for(slot_start))
        available_slots << { starts_at: slot_start, ends_at: ends_at_for(slot_start), dentists: dentists }
      end

      break if limit.present? && available_slots.size >= limit

      slot_start += SLOT_INTERVAL
    end

    available_slots
  end

  def slot_cards
    return [] if clinic_day_closed?

    range_start, range_end = clinic_bounds
    slot_start = range_start
    cards = []

    while slot_start + occupied_duration <= range_end
      ends_at = ends_at_for(slot_start)
      dentists = available_dentists_for(slot_start)
      status, reason = slot_state(slot_start, ends_at, dentists)

      cards << {
        starts_at: slot_start,
        ends_at: ends_at,
        dentists: dentists,
        dentist_name: dentists.first&.name,
        status: status,
        reason: reason,
        period: slot_start.hour < 12 ? "morning" : "afternoon"
      }

      slot_start += SLOT_INTERVAL
    end

    cards
  end

  def clinic_open_for?(starts_at, ends_at, booking_type: "scheduled")
    closure = ClinicClosure.find_by(date: starts_at.to_date)
    return booking_type == "emergency" if closure.present? && !closure.emergency_only?
    return booking_type == "emergency" if closure&.emergency_only?

    schedule = ClinicSchedule.for_date(starts_at.to_date)
    return false if schedule.blank? && ClinicSchedule.exists?
    return true if schedule.blank?
    return booking_type == "emergency" if schedule.closed? || schedule.emergency_only?

    opens_at, closes_at = clinic_bounds(schedule)
    starts_at >= opens_at && ends_at <= closes_at
  end

  def dentist_available?(dentist, starts_at, ends_at, appointment: nil)
    return false unless dentist&.dentist?
    return false unless dentist_within_working_time?(dentist, starts_at, ends_at)
    return false if dentist_conflict?(dentist, starts_at, ends_at, appointment: appointment)

    true
  end

  def clinic_capacity_available?(starts_at, ends_at, appointment: nil)
    max_concurrent = ClinicSchedule.for_date(starts_at.to_date)&.max_concurrent_appointments || Float::INFINITY
    occupied = Appointment.occupying_schedule
                          .where.not(id: appointment&.id)
                          .where("starts_at < ? AND datetime(ends_at, '+' || buffer_minutes || ' minutes') > ?", ends_at, starts_at)
                          .count

    occupied < max_concurrent
  end

  def ends_at_for(starts_at)
    starts_at + occupied_duration
  end

  private

  def slot_state(starts_at, ends_at, dentists)
    return [ "past", "Past time" ] if starts_at < Time.current
    return [ "break", "Clinic is closed" ] unless clinic_open_for?(starts_at, ends_at, booking_type: "scheduled")
    if dentists.any?
      return [ "booked", "Clinic capacity full" ] unless clinic_capacity_available?(starts_at, ends_at)
      return [ "available", nil ]
    end

    return [ "booked", "Already booked" ] if booking_conflict?(starts_at, ends_at)
    return [ "break", "No dentist available" ]
  end

  def clinic_day_closed?
    closure = ClinicClosure.find_by(date: date)
    return true if closure.present? && !closure.emergency_only?
    return true if closure&.emergency_only?

    schedule = ClinicSchedule.for_date(date)
    return true if schedule.blank? && ClinicSchedule.exists?
    return true if schedule&.closed? || schedule&.emergency_only?

    false
  end

  def booking_conflict?(starts_at, ends_at)
    Appointment.occupying_schedule
               .where("starts_at < ? AND datetime(ends_at, '+' || buffer_minutes || ' minutes') > ?", ends_at, starts_at)
               .exists?
  end

  def clinic_open?
    closure = ClinicClosure.find_by(date: date)
    return false if closure.present?

    schedule = ClinicSchedule.for_date(date)
    return false if schedule.blank? && ClinicSchedule.exists?
    return true if schedule.blank?

    !schedule.closed? && !schedule.emergency_only?
  end

  def occupied_duration
    duration_minutes.minutes + preparation_minutes.minutes + buffer_minutes.minutes
  end

  def next_bookable_slot_start
    interval = SLOT_INTERVAL.to_i
    current = Time.current
    Time.zone.at(((current.to_i + interval - 1) / interval) * interval)
  end

  def dentist_within_working_time?(dentist, starts_at, ends_at)
    override = DentistScheduleOverride.find_by(user: dentist, date: starts_at.to_date)
    return false if override&.unavailable?

    if override.present?
      available_from = at_date(starts_at.to_date, override.available_from)
      available_until = at_date(starts_at.to_date, override.available_until)
      return starts_at >= available_from && ends_at <= available_until
    end

    all_schedules = dentist.dentist_schedules.active
    return true if all_schedules.none?

    schedules = all_schedules.for_date(starts_at.to_date)
    schedules.any? do |schedule|
      starts_at >= at_date(starts_at.to_date, schedule.starts_at) &&
        ends_at <= at_date(starts_at.to_date, schedule.ends_at)
    end
  end

  def dentist_conflict?(dentist, starts_at, ends_at, appointment: nil)
    Appointment.occupying_schedule
               .where(user: dentist)
               .where.not(id: appointment&.id)
               .where("starts_at < ? AND datetime(ends_at, '+' || buffer_minutes || ' minutes') > ?", ends_at, starts_at)
               .exists?
  end

  def clinic_bounds(schedule = ClinicSchedule.for_date(date))
    raise ArgumentError, "Clinic schedule is not configured for #{date}" if schedule.blank? && ClinicSchedule.exists?

    opens_at = schedule&.opens_at || Time.zone.parse("08:00")
    closes_at = schedule&.closes_at || Time.zone.parse("17:00")

    [ at_date(date, opens_at), at_date(date, closes_at) ]
  end

  def at_date(day, time)
    Time.zone.local(day.year, day.month, day.day, time.hour, time.min, time.sec)
  end
end
