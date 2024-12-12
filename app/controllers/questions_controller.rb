class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: %i[create]
  before_action :set_quiz, only: [:create]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_bad_id

  # POST /quizzes/:quiz_id/questions
  def create
    @question = @quiz.questions.build(question_params)
    if @question.save
      @quiz.update(number_of_questions: @quiz.questions.count) #increment question count to reflect new question
      respond_to do |format|
        format.turbo_stream
      end  
    else
      flash[:alert] = "There was an error adding the question."
      #render 'quizzes/show', status: :unprocessable_entity
    end
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def question_params
    params.require(:question).permit(:content, :options, :correct_answer)
  end

  def handle_bad_id
    flash[:alert] = "Invalid quiz ID"
    redirect_to quizzes_path
  end
end