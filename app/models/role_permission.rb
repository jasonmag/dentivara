class RolePermission < ApplicationRecord
  PERMISSION_ACTIONS = User::PERMISSION_ACTIONS
  PERMISSION_FEATURES = User::PERMISSION_FEATURES

  enum :role, User.roles, prefix: true

  validates :role, presence: true, uniqueness: true
  before_validation :normalize_permissions_matrix

  def permission_matrix
    matrix = default_permission_matrix
    stored = permissions.to_h.deep_stringify_keys

    PERMISSION_FEATURES.each_key do |feature|
      feature_key = feature.to_s
      next unless stored[feature_key].is_a?(Hash)

      PERMISSION_ACTIONS.each do |action|
        next if stored[feature_key][action].nil?

        matrix[feature_key][action] = ActiveModel::Type::Boolean.new.cast(stored[feature_key][action])
      end
    end

    matrix
  end

  private

  def default_permission_matrix
    PERMISSION_FEATURES.each_with_object({}) do |(feature, _label), matrix|
      matrix[feature.to_s] = PERMISSION_ACTIONS.index_with do |_action|
        role != "patient"
      end
    end
  end

  def normalize_permissions_matrix
    self.permissions = permission_matrix
  end
end
