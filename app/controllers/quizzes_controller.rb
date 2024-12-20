class QuizzesController < ApplicationController
  include QuizzesHelper
  before_action :authenticate_user!, only: %i[new show create edit update destroy]
  before_action :set_quiz, only: [ :show, :edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_bad_id
  #Dummy comment
  # GET /quizzes
  def index
    if user_signed_in?
      @quizzes = if params[:query].present? && params[:query].length > 1 #What is the rationale behind the length check?

                   Quiz.by_search_string(params[:query], current_user)
      else
                   current_user.quizzes
      end
    else
      @quizzes = [] # REPLACE WITH OTHER LOGIC WHEN USER IS NOT LOGGED IN
    end
  end
  
  # GET /quizzes/:id
  def show
    @quiz = Quiz.find(params[:id])
  end

  # GET /quizzes/new
  def new
    @quiz = Quiz.new
  end

  # POST /quizzes
  def create
    @quiz = current_user.quizzes.build(quiz_params) # Associate the quiz with the current_user
    result = generate_questions_with_openai(@quiz, current_user)

    if result[:success]
      result[:generated_questions].each do |question_data| #empty if no quizzes were generated
        @quiz.questions.build(question_data)
      end
      if @quiz.save
        redirect_to quiz_path(@quiz), notice: result[:msg]
      else
        flash.now[:alert] = "Quiz cannot be saved. Please try again."
        render :new, status: :unprocessable_entity
      end
    else # failed generaion
      flash.now[:alert] = "Quiz generation failed. Please reduce the number of questions  or modify your topic and try again."
      Rails.logger.error("Quiz generation error: #{result[:error]}")
      render :new, status: :unprocessable_entity
    end
  end

  # GET /quizzes/:id/edit
  def edit
    @quiz = Quiz.find(params[:id])
    @quiz.questions.build if @quiz.questions.empty? # Build at least one question if none exist
  end

  # PATCH/PUT /quizzes/:id
  def update
    @quiz = Quiz.find params[:id]
    @quiz.number_of_questions = @quiz.questions.count #auto update in response to removed question
    if @quiz.update(quiz_params)
      redirect_to quiz_path(@quiz), notice: "Quiz was successfully updated."
    else
      flash[:alert] = "Quiz update failed."
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /quizzes/:id
  def destroy
    @quiz.destroy
    redirect_to quizzes_url, notice: "Quiz was successfully deleted."
  end

  private
  
  # Find quiz by ID for show, edit, update, destroy actions
  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  # Only allow a list of trusted parameters through
  # In QuizzesController
  def quiz_params
    params.require(:quiz).permit(
      :topic, :difficulty, :study_duration, :detail_level,
      :number_of_questions, questions_attributes: [ :id, :content, :options, :correct_answer, :status, :_destroy ]
    )
  end

  def handle_bad_id
    flash[:alert] = "Invalid quiz ID"
    redirect_to quizzes_path
  end
end
