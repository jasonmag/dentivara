module AppointmentsHelper
  def slot_chip_classes(slot)
    base = "w-full sm:w-auto sm:min-w-[118px] rounded-full border px-4 py-2.5 text-center text-sm font-medium transition focus:outline-none focus:ring-2 whitespace-nowrap inline-flex items-center justify-center min-h-11"

    case slot[:status]
    when "available"
      "#{base} border-[#8BA88E]/40 bg-white text-stone-700 hover:border-[#8BA88E] hover:bg-[#F4FAF5] focus:ring-[#8BA88E]"
    when "booked"
      "#{base} border-stone-200 bg-stone-100 text-stone-400 cursor-not-allowed"
    when "break"
      "#{base} border-amber-200 bg-amber-50 text-amber-700 cursor-not-allowed"
    when "past"
      "#{base} border-stone-200 bg-stone-50 text-stone-400 opacity-70 cursor-not-allowed"
    else
      "#{base} border-stone-200 bg-white text-stone-700"
    end
  end

  def slot_chip_period_label(period)
    period == "morning" ? "Morning" : "Afternoon"
  end

  def slot_chip_status_label(slot)
    case slot[:status]
    when "available"
      "Available"
    when "booked"
      "Booked"
    when "break"
      "Break"
    when "past"
      "Past"
    else
      "Unavailable"
    end
  end

  def appointment_status_badge_classes(status)
    base = "inline-flex items-center rounded-full border px-3 py-1 text-xs font-semibold uppercase tracking-wide"

    "#{base} " + case status
    when "pending"
      "border-amber-200 bg-amber-100 text-amber-800"
    when "confirmed"
      "border-[#8BA88E]/30 bg-[#E8F1E9] text-[#35513a]"
    when "checked_in"
      "border-blue-200 bg-blue-100 text-blue-800"
    when "in_progress"
      "border-teal-200 bg-teal-100 text-teal-800"
    when "completed"
      "border-stone-200 bg-stone-100 text-stone-700"
    when "cancelled"
      "border-red-200 bg-red-100 text-red-800"
    when "no_show"
      "border-rose-200 bg-rose-50 text-rose-700"
    when "rescheduled"
      "border-purple-200 bg-purple-100 text-purple-800"
    else
      "border-stone-200 bg-stone-100 text-stone-700"
    end
  end

  def appointment_card_classes(status)
    base = "group w-full rounded-xl border-l-4 border transition text-left shadow-sm hover:-translate-y-0.5 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-[#8BA88E]/40"

    "#{base} " + case status
    when "pending"
      "border-amber-200 bg-amber-50 hover:border-amber-300"
    when "confirmed"
      "border-[#8BA88E] bg-[#F7FBF7] hover:border-[#7D997F]"
    when "checked_in"
      "border-blue-200 bg-blue-50 hover:border-blue-300"
    when "in_progress"
      "border-teal-200 bg-teal-50 hover:border-teal-300"
    when "completed"
      "border-stone-200 bg-stone-50 hover:border-stone-300"
    when "cancelled"
      "border-red-200 bg-red-50 hover:border-red-300"
    when "no_show"
      "border-rose-200 bg-rose-50 hover:border-rose-300"
    when "rescheduled"
      "border-purple-200 bg-purple-50 hover:border-purple-300"
    else
      "border-stone-200 bg-white hover:border-stone-300"
    end
  end

  def appointment_status_options
    Appointment::STATUSES.map { |status| [ status.humanize, status ] }
  end
end
