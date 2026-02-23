class ReceiptsController < ApplicationController
  before_action :set_receipt, only: [:show, :edit, :update, :destroy]

  def index
    @receipts = current_user.receipts.recent.with_attached_image
    @receipts = @receipts.linked   if params[:filter] == "linked"
    @receipts = @receipts.unlinked if params[:filter] == "unlinked"
  end

  def show
  end

  def new
    @receipt = current_user.receipts.build(receipt_date: Date.today)
  end

  def create
    @receipt = current_user.receipts.build(receipt_params)

    if @receipt.save
      redirect_to @receipt, notice: "Receipt uploaded successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @receipt.update(receipt_params)
      redirect_to @receipt, notice: "Receipt updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @receipt.image.purge
    @receipt.destroy
    redirect_to receipts_path, notice: "Receipt deleted."
  end

  private

  def set_receipt
    @receipt = current_user.receipts.find(params[:id])
  end

  def receipt_params
    params.require(:receipt).permit(:image, :store_name, :amount, :receipt_date, :notes)
  end
end
