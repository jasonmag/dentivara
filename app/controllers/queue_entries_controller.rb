class QueueEntriesController < ApplicationController
  before_action -> { require_permission!(:appointments, :view) }, only: :index
  before_action -> { require_permission!(:appointments, :update) }, only: %i[create call_next call serve cancel]
  before_action :set_queue_entry, only: %i[call serve cancel]

  def index
    load_board_data
  end

  def create
    entry = QueueEntry.new(queue_entry_params)
    entry.queue_type ||= entry.appointment&.booking_type.presence_in(QueueEntry::QUEUE_TYPES) || "scheduled"

    if entry.save
      entry.appointment&.update(status: "checked_in") if entry.appointment&.status.in?(%w[pending confirmed])
      broadcast_queue_board!
      redirect_to queue_entries_path, notice: "Patient added to queue."
    else
      redirect_to queue_entries_path, alert: entry.errors.full_messages.to_sentence
    end
  end

  def call_next
    entry = QueueEntry.next_waiting
    return redirect_to queue_entries_path, alert: "No waiting patients in queue." if entry.blank?

    entry.call!
    broadcast_queue_board!
    redirect_to queue_entries_path, notice: "#{entry.patient.full_name} called next."
  end

  def call
    @queue_entry.call!
    broadcast_queue_board!
    redirect_to queue_entries_path, notice: "#{@queue_entry.patient.full_name} marked as called."
  end

  def serve
    @queue_entry.serve!
    broadcast_queue_board!
    redirect_to queue_entries_path, notice: "#{@queue_entry.patient.full_name} marked as served."
  end

  def cancel
    @queue_entry.cancel!
    broadcast_queue_board!
    redirect_to queue_entries_path, notice: "#{@queue_entry.patient.full_name} removed from active queue."
  end

  private

  def set_queue_entry
    @queue_entry = QueueEntry.find(params.expect(:id))
  end

  def queue_entry_params
    params.expect(queue_entry: [ :appointment_id, :patient_id, :queue_type, :priority_level, :notes ])
  end

  def load_board_data
    @queue_entries = QueueEntry.active.includes(:patient, :appointment).ordered_for_dispatch
    @upcoming_appointments = Appointment.includes(:patient)
                                        .where(status: %w[pending confirmed], starts_at: Time.current.beginning_of_day..Time.current.end_of_day)
                                        .order(:starts_at)
                                        .limit(25)
  end

  def broadcast_queue_board!
    load_board_data

    Turbo::StreamsChannel.broadcast_replace_to(
      "queue_board",
      target: "queue_board",
      partial: "queue_entries/board",
      locals: {
        queue_entries: @queue_entries,
        upcoming_appointments: @upcoming_appointments
      }
    )
  end
end
