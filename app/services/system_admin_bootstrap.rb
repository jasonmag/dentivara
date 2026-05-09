class SystemAdminBootstrap
  def self.from_env!
    email = ENV["ADMIN_EMAIL"].to_s.strip.downcase
    password = ENV["ADMIN_PASSWORD"].to_s

    return nil if email.blank? || password.blank?
    return nil if password.length < 8

    user = User.find_or_initialize_by(email: email)
    user.name = "System Admin"
    user.role = :system_admin
    user.password = password
    user.password_confirmation = password
    user.save!
    user
  end
end
