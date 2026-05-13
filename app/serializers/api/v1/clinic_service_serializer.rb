module Api
  module V1
    class ClinicServiceSerializer
      def self.call(clinic_service)
        {
          id: clinic_service.id,
          name: clinic_service.name,
          description: clinic_service.description,
          base_price: clinic_service.base_price,
          active: clinic_service.active,
          duration_minutes: clinic_service.duration_minutes,
          preparation_minutes: clinic_service.preparation_minutes,
          color: clinic_service.color,
          created_at: clinic_service.created_at,
          updated_at: clinic_service.updated_at
        }
      end
    end
  end
end
