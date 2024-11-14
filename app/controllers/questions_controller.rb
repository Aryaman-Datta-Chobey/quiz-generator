class QuestionsController < ApplicationController
  def create
    @quiz = Quiz.find(params[:quiz_id])
    @question = @quiz.questions.new(question_params)
    
    if @question.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to quiz_path(@quiz), notice: 'Question added successfully' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @quiz = Quiz.find(params[:quiz_id])
    @question = @quiz.questions.find(params[:id])
    @question.destroy
  
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("question_#{@question.id}") }
      format.html { redirect_to quiz_path(@quiz), notice: 'Question deleted successfully' }
    end
  end

  def edit
    @quiz = Quiz.find(params[:quiz_id])
    @question = @quiz.questions.find(params[:id])
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "question_#{@question.id}", 
          partial: "questions/form", 
          locals: { quiz: @quiz, question: @question }
        )
      end
      format.html { head :no_content }  # Avoids needing an HTML view
    end
  end

  def update
    @quiz = Quiz.find(params[:quiz_id])
    @question = @quiz.questions.find(params[:id])
    
    if @question.update(question_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to quiz_path(@quiz), notice: 'Question updated successfully' }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def new
    @quiz = Quiz.find(params[:quiz_id])
    @question = Question.new
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end
  private

  # Define the question_params method to whitelist parameters
  def question_params
    params.require(:question).permit(:content, :options, :correct_answer)
  end
end
