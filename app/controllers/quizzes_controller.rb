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
    prompt = "
      Generate a multiple-choice questions (MCQs) based quiz using the following inputs:
      Topic (of the quiz): #{params[:quiz][:topic]}.
      Number of Questions (in the quiz): #{params[:quiz][:number_of_questions]}.
      Difficulty (of the quiz): #{params[:quiz][:difficulty]}.
      Detail Level (depth of the questions): #{params[:quiz][:detail_level]}.
      Instructions:
      For each question, generate a question and its correct answer (appropriate to the input difficulty and detail level).
      2. Create three plausible but incorrect options (distractors) for each question.
      3. Format the output as valid JSON with this structure:
      {
        \"questions\": [
          {
            \"content\": \"Question text here\",
            \"options\": [\"Option 1\", \"Option 2\", \"Option 3\", \"Option 4\"],
            \"correct_answer\": \"Option 2\"
          },
          ...
        ]
      }
      Ensure the JSON includes all questions.
    "
    begin
      openai_service = OpenaiService.new
      response = openai_service.generate_response(prompt, 5000, "mixtral-8x7b-32768")

      # Parse the JSON string into a Ruby hash
      parsed_response = JSON.parse(response) rescue { error: "Invalid JSON response. Try again." }
      @quiz = current_user.quizzes.build(quiz_params)  # Associate the quiz with the current_user

      # Iterate through the JSON to populate the quiz questions
      parsed_response["questions"].each do |question|
        @quiz.questions.build(question)
      end

      # Iterate thru the JSON to populate the quiz questions
      if @quiz.save
        session[:response_content] = response
        redirect_to quiz_path(@quiz), notice: "Quiz was successfully generated."
      else
        render :new, status: :unprocessable_entity
      end
    rescue JSON::ParserError => e
      flash.now[:alert] = "Invalid JSON response. Try again."
      Rails.logger.error("JSON::ParserError: #{e.message}")
      render :new
    rescue StandardError => e
      flash.now[:alert] = "An error occurred while generating the quiz. Please try again."
      Rails.logger.error("StandardError: #{e.message}")
      render :new
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
