class Notification < ApplicationRecord
  include TenantScoped
  include Auditable

  belongs_to :patient
  belongs_to :source_record, polymorphic: true, optional: true

  CHANNELS = %w[email sms in_app].freeze
  CATEGORIES = %w[appointment follow_up balance billing missed_appointment instruction].freeze
  STATUSES = %w[pending sent failed cancelled].freeze

  validates :channel, inclusion: { in: CHANNELS }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :message, presence: true

  after_commit :queue_dispatch, on: :create

  def sent?
    status == "sent"
  end

  private

  def queue_dispatch
    return unless status == "pending"

    NotificationDispatchJob.perform_later(id)
  end
end
