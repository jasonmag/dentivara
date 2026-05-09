module QueueEntriesHelper
  def queue_eta_label(entry)
    case entry.status
    when "called"
      "Being called now"
    when "waiting"
      clinic_setting = ClinicSetting.current
      per_patient_minutes = clinic_setting.queue_eta_minutes_for(entry.queue_type)
      minutes = [ (entry.position - 1) * per_patient_minutes, 0 ].max
      return "Next up" if minutes.zero?

      "Approx #{minutes} min wait"
    else
      "N/A"
    end
  end
end
