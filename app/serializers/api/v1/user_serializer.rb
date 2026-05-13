module Api
  module V1
    class UserSerializer
      def self.call(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          clinic_id: user.clinic_id,
          clinic: user.clinic.present? ? ClinicSerializer.call(user.clinic) : nil,
          clinics: user.accessible_clinics.map { |clinic| ClinicSerializer.call(clinic) },
          permissions: user.permission_matrix,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end
