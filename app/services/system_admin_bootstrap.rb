class SystemAdminBootstrap
  def self.from_env!
    email = ENV["ADMIN_EMAIL"].to_s.strip.downcase
    password = ENV["ADMIN_PASSWORD"].to_s
    name = ENV["ADMIN_NAME"].to_s.strip.presence || "System Admin"

    return nil if email.blank? || password.blank?
    return nil if password.length < 8

    user = User.find_or_initialize_by(email: email)
    user.name = name
    user.role = :system_admin
    user.password = password
    user.password_confirmation = password
    user.save!
    user
  end
end
