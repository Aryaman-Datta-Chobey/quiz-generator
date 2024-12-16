include ActionView::RecordIdentifier
class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: %i[create edit update destroy]
  before_action :set_quiz, only: %i[create edit update destroy]
  before_action :set_question, only: %i[edit update destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :handle_bad_id

  # POST /quizzes/:quiz_id/questions
  def create
    @question = @quiz.questions.build(question_params)
    if @question.save
      @quiz.update(number_of_questions: @quiz.questions.count) #increment question count to reflect new question
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
          turbo_stream.append('questions_list', partial: "questions/question", locals: { question: @question, quiz: @quiz }),
          turbo_stream.replace('quiz-question-count', partial: "quizzes/question_count", locals: { quiz: @quiz })
        ]
        end
        format.html{ redirect_to edit_quiz_path(@quiz), notice: "Question added successfully." }
      end   
    else
      flash[:alert] = "There was an error adding the question."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @question = @quiz.questions.find(params[:id])
    render turbo_stream: turbo_stream.update(dom_id(@question), partial: "questions/question_form", locals: { quiz: @quiz, question: @question, submit_label: "Save Question" })
  end

  def update
    @question = @quiz.questions.find(params[:id])
    if @question.update(question_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@question),
            partial: "questions/question",
            locals: { quiz: @quiz, question: @question }
          )
        end
        format.html { redirect_to edit_quiz_path(@quiz), notice: "Question updated successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@question),
            partial: "questions/question_form",
            locals: { quiz: @quiz, question: @question, submit_label: "Save Question" }
          )
        end
        format.html { redirect_to edit_quiz_path(@quiz), status: :unprocessable_entity }
      end
    end
  end
  

  def destroy
    @question.destroy
    @quiz.update(number_of_questions: @quiz.questions.count) #decrement question count to reflect new question
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(dom_id(@question)),
          turbo_stream.replace('quiz-question-count', partial: "quizzes/question_count", locals: { quiz: @quiz })
        ]
      end
      format.html{ redirect_to edit_quiz_path(@quiz), notice: "Question deleted successfully." }
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