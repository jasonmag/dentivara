class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[ show edit update destroy receipt ]
  before_action -> { require_permission!(:payments, :view) }, only: %i[index show receipt]
  before_action -> { require_permission!(:payments, :create) }, only: %i[new create]
  before_action -> { require_permission!(:payments, :update) }, only: %i[edit update]
  before_action -> { require_permission!(:payments, :destroy) }, only: :destroy

  # GET /payments or /payments.json
  def index
    @payments = Payment.includes(invoice: :patient).order(paid_on: :desc)
  end

  # GET /payments/1 or /payments/1.json
  def show
  end

  # GET /payments/new
  def new
    @payment = Payment.new(invoice_id: params[:invoice_id], paid_on: Time.zone.today)
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments or /payments.json
  def create
    @payment = Payment.new(payment_params)
    @payment.recorded_by ||= current_user

    respond_to do |format|
      if @payment.save
        format.html { redirect_to after_payment_save_path(@payment), notice: "Payment was successfully recorded." }
        format.turbo_stream { redirect_to after_payment_save_path(@payment), notice: "Payment was successfully recorded." }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1 or /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to after_payment_save_path(@payment), notice: "Payment was successfully updated.", status: :see_other }
        format.turbo_stream { redirect_to after_payment_save_path(@payment), notice: "Payment was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1 or /payments/1.json
  def destroy
    invoice = @payment.invoice
    @payment.destroy!

    respond_to do |format|
      format.html { redirect_to invoice_path(invoice), notice: "Payment was successfully voided.", status: :see_other }
      format.turbo_stream { redirect_to invoice_path(invoice), notice: "Payment was successfully voided.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def receipt
    pdf_data = Billing::ReceiptPdfRenderer.new(@payment).render
    send_data pdf_data,
              filename: "receipt-#{@payment.id}.pdf",
              type: "application/pdf",
              disposition: "attachment"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.expect(payment: [ :invoice_id, :amount, :paid_on, :method, :reference_code, :notes, :proof, :recorded_by_user_id ])
    end

    def after_payment_save_path(payment)
      invoice_id = params[:invoice_id].presence || payment.invoice_id
      return payment_path(payment) if invoice_id.blank?

      invoice_path(invoice_id)
    end
end
