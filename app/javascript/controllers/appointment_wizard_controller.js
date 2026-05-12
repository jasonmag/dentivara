import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "step",
    "indicator",
    "previousButton",
    "nextButton",
    "submitButton",
    "stepError",
    "calendar",
    "patient",
    "clinicService",
    "assignedUser",
    "timePreference",
    "timePreferencePill",
    "startsAt",
    "endsAt",
    "specificTimeField",
    "selectedSlot",
    "selectedSlotEmpty",
    "selectedSlotDetails",
    "selectedSlotState",
    "selectedSlotDentist",
    "selectedSlotDate",
    "selectedSlotTime",
    "selectedSlotProcedure",
    "selectedSlotDuration",
    "selectedSlotRoomChair"
  ]
  static values = { slotsUrl: String }

  connect() {
    this.currentStep = 0
    this.toggleSpecificTimeFields()
    this.updateTimePreferencePills()
    this.showCurrentStep()
  }

  next() {
    if (this.currentStep >= this.stepTargets.length - 1) return
    if (this.currentStep === 0 && !this.firstStepComplete()) return

    this.currentStep += 1
    this.showCurrentStep()
  }

  previous() {
    if (this.currentStep <= 0) return

    this.currentStep -= 1
    this.showCurrentStep()
  }

  refreshSlots() {
    this.clearSelectedSlot()
    this.clearStepError()
    this.syncFirstStepFieldStates()
    this.updateTimePreferencePills()
    if ((!this.hasTimePreferenceTarget || this.timePreferenceTarget.value !== "specific_time") && this.hasStartsAtTarget && this.hasEndsAtTarget) {
      this.startsAtTarget.value = ""
      this.endsAtTarget.value = ""
    }

    this.loadSlots({
      slotView: this.calendarTarget.dataset.slotView || "week",
      slotDate: this.calendarTarget.dataset.slotDate
    })
  }

  setTimePreference(event) {
    if (!this.hasTimePreferenceTarget) return

    this.timePreferenceTarget.value = event.currentTarget.dataset.timePreferenceValue || ""
    this.updateTimePreferencePills()
    this.refreshSlots()
  }

  selectSlot(event) {
    this.startsAtTarget.value = event.currentTarget.dataset.startsAt
    this.endsAtTarget.value = event.currentTarget.dataset.endsAt
    this.clearStepError()

    this.showSelectedSlot({
      dentistName: event.currentTarget.dataset.dentistName,
      dateLabel: event.currentTarget.dataset.dateLabel,
      timeLabel: event.currentTarget.dataset.timeLabel,
      procedureName: event.currentTarget.dataset.procedureName,
      durationLabel: event.currentTarget.dataset.durationLabel,
      roomChairLabel: event.currentTarget.dataset.roomChairLabel,
      stateLabel: event.currentTarget.dataset.stateLabel
    })

    this.syncSelectedSlotState(event.currentTarget)
  }

  changeSlotView(event) {
    this.loadSlots({
      slotView: event.currentTarget.dataset.slotView,
      slotDate: this.calendarTarget.dataset.slotDate
    })
  }

  previousSlotRange() {
    this.loadSlots({ slotDate: this.shiftedSlotDate(-1) })
  }

  nextSlotRange() {
    this.loadSlots({ slotDate: this.shiftedSlotDate(1) })
  }

  showCurrentStep() {
    this.stepTargets.forEach((step, index) => {
      step.hidden = index !== this.currentStep
    })

    this.indicatorTargets.forEach((indicator, index) => {
      indicator.classList.toggle("border-[#8BA88E]", index <= this.currentStep)
      indicator.classList.toggle("bg-[#E8F1E9]", index === this.currentStep)
      indicator.classList.toggle("text-stone-800", index === this.currentStep)
      indicator.classList.toggle("border-stone-200", index > this.currentStep)
      indicator.classList.toggle("text-stone-500", index !== this.currentStep)
    })

    this.previousButtonTarget.disabled = this.currentStep === 0
    this.nextButtonTarget.hidden = this.currentStep === this.stepTargets.length - 1
    this.submitButtonTarget.hidden = this.currentStep !== this.stepTargets.length - 1
  }

  loadSlots({ slotView = this.calendarTarget.dataset.slotView || "week", slotDate = this.calendarTarget.dataset.slotDate } = {}) {
    const params = new URLSearchParams()
    params.set("slot_view", slotView)
    if (slotDate) params.set("slot_date", slotDate)
    if (this.hasClinicServiceTarget && this.clinicServiceTarget.value) params.set("clinic_service_id", this.clinicServiceTarget.value)
    if (this.hasAssignedUserTarget && this.assignedUserTarget.value) params.set("user_id", this.assignedUserTarget.value)
    if (this.hasTimePreferenceTarget && this.timePreferenceTarget.value) params.set("time_preference", this.timePreferenceTarget.value)
    if (this.hasStartsAtTarget && this.startsAtTarget.value) params.set("starts_at", this.startsAtTarget.value)
    if (this.hasEndsAtTarget && this.endsAtTarget.value) params.set("ends_at", this.endsAtTarget.value)

    fetch(`${this.slotsUrlValue}?${params.toString()}`, {
      headers: { Accept: "text/html" }
    })
      .then((response) => response.text())
      .then((html) => {
        this.calendarTarget.innerHTML = html
        this.calendarTarget.dataset.slotView = slotView
        this.calendarTarget.dataset.slotDate = slotDate
        this.syncSelectedSlotState()
        this.scrollToPrimarySlot()
      })
  }

  shiftedSlotDate(direction) {
    const currentDate = new Date(`${this.calendarTarget.dataset.slotDate}T00:00:00`)
    const slotView = this.calendarTarget.dataset.slotView || "week"

    if (slotView === "month") {
      currentDate.setMonth(currentDate.getMonth() + direction)
    } else {
      currentDate.setDate(currentDate.getDate() + (direction * 7))
    }

    return currentDate.toISOString().slice(0, 10)
  }

  toggleSpecificTimeFields() {
    if (!this.hasSpecificTimeFieldTarget) return

    const showSpecificTime = this.hasTimePreferenceTarget && this.timePreferenceTarget.value === "specific_time"

    this.specificTimeFieldTargets.forEach((field) => {
      field.hidden = !showSpecificTime
    })
  }

  clearSelectedSlot() {
    if (!this.hasSelectedSlotTarget) return

    this.selectedSlotTarget.classList.add("hidden")
    if (this.hasSelectedSlotEmptyTarget) this.selectedSlotEmptyTarget.classList.remove("hidden")
    if (this.hasSelectedSlotDetailsTarget) this.selectedSlotDetailsTarget.classList.add("hidden")
    if (this.hasSelectedSlotStateTarget) this.selectedSlotStateTarget.textContent = ""
    if (this.hasSelectedSlotDentistTarget) this.selectedSlotDentistTarget.textContent = ""
    if (this.hasSelectedSlotDateTarget) this.selectedSlotDateTarget.textContent = ""
    if (this.hasSelectedSlotTimeTarget) this.selectedSlotTimeTarget.textContent = ""
    if (this.hasSelectedSlotProcedureTarget) this.selectedSlotProcedureTarget.textContent = ""
    if (this.hasSelectedSlotDurationTarget) this.selectedSlotDurationTarget.textContent = ""
    if (this.hasSelectedSlotRoomChairTarget) this.selectedSlotRoomChairTarget.textContent = ""
  }

  showSelectedSlot(details) {
    if (!this.hasSelectedSlotTarget) return

    this.selectedSlotTarget.classList.remove("hidden")
    if (this.hasSelectedSlotEmptyTarget) this.selectedSlotEmptyTarget.classList.add("hidden")
    if (this.hasSelectedSlotDetailsTarget) this.selectedSlotDetailsTarget.classList.remove("hidden")
    if (this.hasSelectedSlotStateTarget) this.selectedSlotStateTarget.textContent = details.stateLabel || "Selected"
    if (this.hasSelectedSlotDentistTarget) this.selectedSlotDentistTarget.textContent = details.dentistName || "Any available dentist"
    if (this.hasSelectedSlotDateTarget) this.selectedSlotDateTarget.textContent = details.dateLabel || "TBD"
    if (this.hasSelectedSlotTimeTarget) this.selectedSlotTimeTarget.textContent = details.timeLabel || "TBD"
    if (this.hasSelectedSlotProcedureTarget) this.selectedSlotProcedureTarget.textContent = details.procedureName || "Procedure"
    if (this.hasSelectedSlotDurationTarget) this.selectedSlotDurationTarget.textContent = details.durationLabel || "TBD"
    if (this.hasSelectedSlotRoomChairTarget) this.selectedSlotRoomChairTarget.textContent = details.roomChairLabel || "To be assigned"
  }

  firstStepComplete() {
    const patientSelected = this.hasPatientTarget && this.patientTarget.value
    const serviceSelected = this.hasClinicServiceTarget && this.clinicServiceTarget.value

    this.clearStepFieldState(this.patientTarget)
    this.clearStepFieldState(this.clinicServiceTarget)

    if (patientSelected && serviceSelected) {
      this.clearStepError()
      return true
    }

    const missing = []

    if (!patientSelected) {
      missing.push("patient")
      this.markStepFieldInvalid(this.patientTarget)
    }

    if (!serviceSelected) {
      missing.push("service / procedure")
      this.markStepFieldInvalid(this.clinicServiceTarget)
    }

    this.showStepError(`Select ${missing.join(" and ")} before continuing.`)
    return false
  }

  showStepError(message) {
    if (!this.hasStepErrorTarget) return

    this.stepErrorTarget.textContent = message
    this.stepErrorTarget.classList.remove("hidden")
  }

  clearStepError() {
    if (!this.hasStepErrorTarget) return

    this.stepErrorTarget.textContent = ""
    this.stepErrorTarget.classList.add("hidden")
  }

  markStepFieldInvalid(field) {
    if (!field) return

    field.classList.add("border-red-300", "ring-1", "ring-red-300")
  }

  clearStepFieldState(field) {
    if (!field) return

    field.classList.remove("border-red-300", "ring-1", "ring-red-300")
  }

  syncFirstStepFieldStates() {
    if (this.hasPatientTarget && this.patientTarget.value) {
      this.clearStepFieldState(this.patientTarget)
    }

    if (this.hasClinicServiceTarget && this.clinicServiceTarget.value) {
      this.clearStepFieldState(this.clinicServiceTarget)
    }
  }

  updateTimePreferencePills() {
    if (!this.hasTimePreferenceTarget || !this.hasTimePreferencePillTarget) return

    const selectedValue = this.timePreferenceTarget.value || ""

    this.timePreferencePillTargets.forEach((pill) => {
      const isSelected = (pill.dataset.timePreferenceValue || "") === selectedValue
      pill.classList.toggle("border-[#8BA88E]", isSelected)
      pill.classList.toggle("bg-[#E8F1E9]", isSelected)
      pill.classList.toggle("text-[#3D6A42]", isSelected)
      pill.classList.toggle("shadow-sm", isSelected)
      pill.classList.toggle("border-stone-200", !isSelected)
      pill.classList.toggle("bg-white", !isSelected)
      pill.classList.toggle("text-stone-600", !isSelected)
    })
  }

  syncSelectedSlotState(selectedButton = null) {
    if (!this.hasCalendarTarget) return

    const startsAt = this.hasStartsAtTarget ? this.startsAtTarget.value : ""
    const endsAt = this.hasEndsAtTarget ? this.endsAtTarget.value : ""
    const buttons = this.calendarTarget.querySelectorAll("[data-slot-state]")

    buttons.forEach((button) => {
      const isSelected = startsAt && endsAt && button.dataset.startsAt === startsAt && button.dataset.endsAt === endsAt
      button.dataset.selected = isSelected ? "true" : "false"
      button.classList.toggle("ring-2", isSelected)
      button.classList.toggle("ring-[#6A8CF3]", isSelected)
      button.classList.toggle("border-[#6A8CF3]", isSelected)
      button.classList.toggle("border-[#8BA88E]/40", !isSelected)
      button.classList.toggle("shadow-md", isSelected)
      button.classList.toggle("bg-[#6A8CF3]", isSelected)
      button.classList.toggle("text-white", isSelected)
      button.classList.toggle("bg-white", !isSelected)
      button.classList.toggle("text-stone-700", !isSelected)
      button.classList.toggle("hover:bg-[#F4FAF5]", !isSelected)
      button.classList.toggle("hover:border-[#8BA88E]", !isSelected)
    })

    if (selectedButton) {
      selectedButton.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" })
    }
  }

  scrollToPrimarySlot() {
    if (!this.hasCalendarTarget) return

    const selectedButton = this.findSelectedSlotButton()
    if (selectedButton) {
      selectedButton.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" })
      return
    }

    const earliestAvailable = this.calendarTarget.querySelector('[data-slot-state="available"]')
    if (earliestAvailable) {
      earliestAvailable.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" })
    }
  }

  findSelectedSlotButton() {
    if (!this.hasStartsAtTarget || !this.hasEndsAtTarget) return null

    return this.calendarTarget.querySelector(
      `[data-slot-state="available"][data-starts-at="${this.startsAtTarget.value}"][data-ends-at="${this.endsAtTarget.value}"]`
    )
  }
}
