class QueueEntry < ApplicationRecord
  include Auditable

  QUEUE_TYPES = %w[scheduled walk_in emergency priority].freeze
  STATUSES = %w[waiting called served cancelled].freeze

  belongs_to :appointment, optional: true
  belongs_to :patient

  validates :queue_type, inclusion: { in: QUEUE_TYPES }
  validates :status, inclusion: { in: STATUSES }
  validates :priority_level, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :appointment_id, uniqueness: { scope: :status, conditions: -> { where(status: %w[waiting called]) } }, allow_nil: true

  before_validation :default_arrived_at, on: :create
  after_commit :resequence_waiting_positions, on: %i[create update destroy]

  scope :active, -> { where(status: %w[waiting called]) }
  scope :waiting, -> { where(status: "waiting") }
  scope :ordered_for_dispatch, -> { order(priority_level: :desc, arrived_at: :asc, created_at: :asc) }

  def self.next_waiting
    waiting.ordered_for_dispatch.first
  end

  def call!
    transaction do
      update!(status: "called", called_at: Time.current)
      appointment&.update!(status: "checked_in")
    end
  end

  def serve!
    transaction do
      update!(status: "served", served_at: Time.current)
      appointment&.update!(status: "in_progress") if appointment&.status == "checked_in"
    end
  end

  def cancel!
    update!(status: "cancelled")
  end

  private

  def default_arrived_at
    self.arrived_at ||= Time.current
  end

  def resequence_waiting_positions
    QueueEntry.waiting.ordered_for_dispatch.each_with_index do |entry, index|
      next if entry.position == index + 1

      entry.update_column(:position, index + 1)
    end
  end
end
