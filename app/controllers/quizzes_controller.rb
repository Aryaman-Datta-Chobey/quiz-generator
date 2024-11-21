class QuizzesController < ApplicationController
  before_action :authenticate_user!, only: %i[new show create edit update destroy]
  before_action :set_quiz, only: [ :show, :edit, :update, :destroy ]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_bad_id
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
    @quiz = current_user.quizzes.build(quiz_params)  # Associate the quiz with the current_user
    service = OpenAIService.new
    prompt = params[:prompt]
    @response = service.generate_response(prompt)
    if @quiz.save
      redirect_to quizzes_path, notice: "Quiz was successfully generated."
    else
      flash[:alert] = "Quiz could not be created"
      render :new, status: :unprocessable_entity
    end
  end

  # GET /quizzes/:id/edit
  def edit
    @quiz = Quiz.find(params[:id])
  end

  # PATCH/PUT /quizzes/:id
  def update
    @quiz = Quiz.find params[:id]
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

  private
    # Only allow a list of trusted parameters through
    # In QuizzesController
    def quiz_params
      params.require(:quiz).permit(
        :topic, :difficulty, :study_duration, :detail_level,
        :number_of_questions, questions_attributes: [ :id, :content, :options, :correct_answer ]
      )
    end

    def handle_bad_id
      flash[:alert] = "Invalid quiz ID"
      redirect_to quizzes_path
    end
end
