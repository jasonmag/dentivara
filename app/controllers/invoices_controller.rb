class InvoicesController < ApplicationController
  include AccessTrackable

  before_action :set_invoice, only: %i[ show edit update destroy ]

  # GET /invoices or /invoices.json
  def index
    @invoices = Invoice.includes(:patient, :treatment_record).order(updated_at: :desc)
    @monthly_revenue = Payment.where(paid_on: Time.zone.today.beginning_of_month..Time.zone.today.end_of_month).sum(:amount)
    @outstanding_balance = Invoice.sum(:balance_amount)
    @claim_success_rate = 98.2
  end

  # GET /invoices/1 or /invoices/1.json
  def show
    track_access!(resource: @invoice, action: "view_invoice")
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to @invoice, notice: "Invoice was successfully created." }
        format.turbo_stream { redirect_to @invoice, notice: "Invoice was successfully created." }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to @invoice, notice: "Invoice was successfully updated.", status: :see_other }
        format.turbo_stream { redirect_to @invoice, notice: "Invoice was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    @invoice.destroy!

    respond_to do |format|
      format.html { redirect_to invoices_path, notice: "Invoice was successfully destroyed.", status: :see_other }
      format.turbo_stream { redirect_to invoices_path, notice: "Invoice was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def invoice_params
      params.expect(invoice: [ :patient_id, :treatment_record_id, :status, :total_amount, :balance_amount, :issued_on, :approved_by_dentist_at, :approved_by_admin_at ])
    end
end
