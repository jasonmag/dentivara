class AccessLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :resource_type, :resource_id, :action, presence: true
end
