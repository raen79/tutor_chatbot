class FaqsController < ApplicationController
  before_action :set_faq, only: [:show, :update, :destroy]

  def index
    @faqs = faqs.where(:coursework_id => params[:coursework_id])
  end

  def show
  end

  def create
    @faq = faqs.new(faq_params)
    @faq.lecturer_id = current_user.lecturer_id

    if @faq.save
      render :show, status: :created, location: faq_url(:coursework_id => @faq.coursework_id, :id => @faq.id)
    else
      render json: @faq.errors, status: :unprocessable_entity
    end
  end

  def update
    if @faq.update(faq_params)
      render :show, status: :ok, location: faq_url(:coursework_id => @faq.coursework_id, :id => @faq.id)
    else
      render json: @faq.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @faq.destroy
  end

  def find_answer
    @answer = Faq.find_answer(
      :question => params[:question],
      :student_id => current_user.student_id,
      :lecturer_id => params[:lecturer_id],
      :module_id => params[:module_id],
      :coursework_id => params[:coursework_id]
    )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_faq
      begin
        @faq = faqs.find(params[:id])
      rescue
        head :not_found
      end
    end

    def faqs
      current_user.faqs
    end

    def faq_params
      params.require(:faq).permit(:question, :answer, :lecturer_id, :module_id, :coursework_id)
    end
end
