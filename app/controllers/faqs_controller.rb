class FaqsController < ApplicationController
  before_action :set_faq, only: [:show, :update, :destroy]

  def index
    @faqs = Faq.all
  end

  def show
  end

  def create
    @faq = Faq.new(faq_params)

    if @faq.save
      render :show, status: :created, location: @faq
    else
      render json: @faq.errors, status: :unprocessable_entity
    end
  end

  def update
    if @faq.update(faq_params)
      render :show, status: :ok, location: @faq
    else
      render json: @faq.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @faq.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_faq
      @faq = Faq.find(params[:id])
    end

    def faq_params
      params.require(:faq).permit(:question, :answer, :lecturer_id, :module_id, :coursework_id)
    end
end
