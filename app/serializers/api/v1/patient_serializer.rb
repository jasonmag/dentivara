module Api
  module V1
    class PatientSerializer
      def self.call(patient)
        {
          id: patient.id,
          first_name: patient.first_name,
          last_name: patient.last_name,
          full_name: patient.full_name,
          birth_date: patient.birth_date,
          phone: patient.phone,
          email: patient.email,
          emergency_contact_name: patient.emergency_contact_name,
          emergency_contact_phone: patient.emergency_contact_phone,
          medical_history: patient.medical_history,
          consented_at: patient.consented_at,
          chief_complaint: patient.chief_complaint,
          known_allergies: patient.known_allergies,
          current_medications: patient.current_medications,
          medical_conditions: patient.medical_conditions,
          last_dental_visit_on: patient.last_dental_visit_on,
          address_line1: patient.address_line1,
          address_line2: patient.address_line2,
          city: patient.city,
          state: patient.state,
          postal_code: patient.postal_code,
          country: patient.country,
          preferred_contact_method: patient.preferred_contact_method,
          insurance_provider: patient.insurance_provider,
          insurance_policy_number: patient.insurance_policy_number,
          created_at: patient.created_at,
          updated_at: patient.updated_at
        }
      end
    end
  end
end
