sample_users = [
  { name: "Clinic Owner", email: "owner@dentivara.local", role: :clinic_owner },
  { name: "Dr. Maria Reyes", email: "dentist@dentivara.local", role: :dentist },
  { name: "Ana Cruz", email: "reception@dentivara.local", role: :receptionist },
  { name: "Paolo Santos", email: "billing@dentivara.local", role: :billing_staff },
  { name: "Patient User", email: "patient@dentivara.local", role: :patient },
  { name: "System Admin", email: "sysadmin@dentivara.local", role: :system_admin }
]

sample_users.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  user.name = attrs[:name]
  user.role = attrs[:role]
  user.save!
end
#   end
