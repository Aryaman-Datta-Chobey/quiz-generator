class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: %i[create show edit update destroy]
  before_action :set_quiz, only: %i[create show edit update destroy]
  before_action :set_question, only: %i[show edit update destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_bad_id

  # POST /quizzes/:quiz_id/questions
  def create
    @question = @quiz.questions.build(question_params)
    if @question.save
      @quiz.update(number_of_questions: @quiz.questions.count) #increment question count to reflect new question
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_quiz_path(@quiz), notice: "Question added successfully." }
      end  
    else
      flash[:alert] = "There was an error adding the question."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @question.update(question_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to edit_quiz_path(@quiz), notice: "Question updated successfully." }
      end
    else
      render :edit
    end
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to edit_quiz_path(@quiz), notice: "Question deleted successfully." }
    end
  end
  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def question_params
    params.require(:question).permit(:content, :options, :correct_answer)
  end

  def set_question
    @question = @quiz.questions.find(params[:id])
  end

  def handle_bad_id
    flash[:alert] = "Invalid quiz ID"
    redirect_to quizzes_path
  end
end