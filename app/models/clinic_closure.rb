class ClinicClosure < ApplicationRecord
  validates :date, presence: true, uniqueness: true
end
