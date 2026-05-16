class SubscriptionPlan < ApplicationRecord
  validates :name, :code, presence: true
  validates :code, uniqueness: true, format: {
    with: /\A[a-z0-9]+(?:_[a-z0-9]+)*\z/,
    message: "can only contain lowercase letters, numbers, and underscores"
  }
  validates :price_per_month, :clinics_included, :extra_clinic_price,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            allow_nil: true

  before_validation :assign_code

  scope :ordered, -> { order(:position, :name) }

  private

  def assign_code
    self.code = name.to_s.parameterize(separator: "_") if code.blank? && name.present?
  end
end
