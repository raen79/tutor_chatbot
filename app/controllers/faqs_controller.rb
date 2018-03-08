# @tag Faqs
# API for creating, deleting, listing, and finding user Frequently Asked Questions. 
class FaqsController < ApplicationController
  before_action :set_faq, only: [:show, :update, :destroy]

  # Returns the list of FAQs for a specific lecturer's coursework
  # @response_status 200
  # @response_root faqs
  # @response_class Array<Faq>
  # Should include `Authorization` header with a jwt token retrieved from an authentication service at each request.
  def index
    @faqs = faqs.where(:coursework_id => params[:coursework_id])
  end

  # Returns an FAQ
  # @response_status 200
  # @response_class Faq
  # Should include `Authorization` header with a jwt token retrieved from an authentication service at each request.
  def show
  end

  # Creates an FAQ for a specific coursework
  # @response_status 201
  # @response_class Faq
  # @body_parameter [Faq] faq
  # Should include `Authorization` header with a jwt token retrieved from an authentication service at each request.
  def create
    @faq = faqs.new(faq_params)
    @faq.lecturer_id = current_user.lecturer_id
    @faq.coursework_id = params[:coursework_id]

    if @faq.save
      render :show, status: :created, location: faq_url(:coursework_id => @faq.coursework_id, :id => @faq.id)
    else
      render json: @faq.errors, status: :unprocessable_entity
    end
  end

  # Updates an FAQ
  # @response_status 201
  # @response_class Faq
  # @body_parameter [Faq] faq
  # Should include `Authorization` header with a jwt token retrieved from an authentication service at each request.
  def update
    if @faq.update(faq_params)
      render :show, status: :ok, location: faq_url(:coursework_id => @faq.coursework_id, :id => @faq.id)
    else
      render json: @faq.errors, status: :unprocessable_entity
    end
  end

  # Deletes an FAQ
  # @response_status 204
  # Should include `Authorization` header with a jwt token retrieved from an authentication service at each request.
  def destroy
    @faq.destroy
  end

  # Replies to a user's question. Notifies lecturer if no answer is found.
  # @response_status 200
  # @response_class Answer
  # @query_parameter [string] question
  # @query_parameter [string] lecturer_id
  # @query_parameter [string] module_id
  # Should include `Authorization` header with a jwt token retrieved from an authentication service at each request.
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
