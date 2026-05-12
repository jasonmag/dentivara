module InvoicesHelper
  def invoice_display_number(invoice)
    invoice.invoice_number.presence || "INV-#{invoice.id}"
  end

  def invoice_status_badge_classes(status)
    base = "inline-flex items-center rounded-full border px-3 py-1 text-xs font-semibold uppercase tracking-wide"

    "#{base} " + case status
    when "draft"
      "border-stone-200 bg-stone-100 text-stone-700"
    when "for_approval"
      "border-amber-200 bg-amber-100 text-amber-800"
    when "approved"
      "border-[#8BA88E]/30 bg-[#E8F1E9] text-[#35513a]"
    when "partially_paid"
      "border-amber-200 bg-amber-50 text-amber-700"
    when "paid"
      "border-green-200 bg-green-100 text-green-800"
    when "overpaid"
      "border-blue-200 bg-blue-100 text-blue-800"
    when "cancelled", "refunded"
      "border-red-200 bg-red-50 text-red-700"
    else
      "border-stone-200 bg-stone-100 text-stone-700"
    end
  end

  def invoice_payment_status_label(invoice)
    case invoice.status
    when "overpaid"
      "Credit/Overpaid"
    when "partially_paid"
      "Partially Paid"
    else
      invoice.status.humanize
    end
  end
end
