module PrescriptionsHelper
  def prescription_preview_payload(patient, prescription)
    doctor = prescription.signed_by_user || User.where(role: :dentist).order(:name).first || prescription.drafted_by_user

    if prescription.document_template.present?
      rendered = prescription.document_template.render_for(
        patient: patient,
        dentist: doctor,
        context: { today: prescription.issued_on.to_s }
      )
      information_header, body = split_prescription_content_for_preview(prescription.body, rendered)
      rendered[:information_header] = information_header if information_header.present?
      rendered[:body] = body
      rendered
    else
      clinic_name = ENV.fetch("CLINIC_NAME", "Dentivara Dental Clinic")
      clinic_address = ENV.fetch("CLINIC_ADDRESS", "123 Dental Street, Makati City, NCR")
      clinic_contact_number = ENV.fetch("CLINIC_CONTACT_NUMBER", "+63 2 8123 4567")

      {
        header: [clinic_name, clinic_address, clinic_contact_number].join("\n"),
        information_header: [
          "Patient Name: #{patient.full_name}",
          "Date: #{prescription.issued_on}",
          "Diagnosis: #{patient.chief_complaint.presence || "Dental consultation"}"
        ].join("\n"),
        body: prescription.body,
        footer: [clinic_name, clinic_address, clinic_contact_number].join("\n"),
        signature_name: doctor&.name || "Assigned Doctor",
        signature_title: "Licensed Dentist"
      }
    end
  end

  private

  def split_prescription_content_for_preview(body, rendered)
    text = body.to_s.strip
    header = rendered[:header].to_s.strip
    information_header = rendered[:information_header].to_s.strip
    footer = rendered[:footer].to_s.strip

    text = text.delete_prefix(header).strip if header.present? && text.start_with?(header)
    text = text.delete_suffix(footer).strip if footer.present? && text.end_with?(footer)
    if information_header.present? && text.start_with?(information_header)
      text = text.delete_prefix(information_header).strip
      return [information_header, text.presence || rendered[:body]]
    end

    if text.include?("\n\n")
      custom_information_header, custom_body = text.split(/\n{2,}/, 2)
      return [custom_information_header.strip, custom_body.strip] if custom_body.present?
    end

    [information_header, text.presence || rendered[:body]]
  end
end
