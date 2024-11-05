class QuizzesController < ApplicationController
    before_action :set_quiz, only: [ :show, :edit, :update, :destroy ]

    # GET /quizzes
    def index
      @quizzes = Quiz.all
      if params[:query].present? && params[:query].length > 2
        @quizzes = @quizzes.by_search_string(params[:query])
      end
    end

    # GET /quizzes/:id
    def show
    end

    # GET /quizzes/new
    def new
      @quiz = Quiz.new
    end

    # POST /quizzes
    def create
      @quiz = Quiz.new(quiz_params)
      if @quiz.save
        redirect_to @quiz, notice: "Quiz was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # GET /quizzes/:id/edit
    def edit
    end

    # PATCH/PUT /quizzes/:id
    def update
      if @quiz.update(quiz_params)
        redirect_to @quiz, notice: "Quiz was successfully updated."
      else
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
    def quiz_params
      params.require(:quiz).permit(:topic, :difficulty, :study_duration, :detail_level, :number_of_questions, :score)
    end
end
