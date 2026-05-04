class Notification < ApplicationRecord
  belongs_to :patient

  CHANNELS = %w[email sms in_app].freeze
  CATEGORIES = %w[appointment follow_up balance billing missed_appointment instruction].freeze
  STATUSES = %w[pending sent failed cancelled].freeze

  validates :channel, inclusion: { in: CHANNELS }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :message, presence: true
end
