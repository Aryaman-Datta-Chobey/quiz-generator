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
      format.turbo_stream
      format.html { redirect_to quiz_path(@quiz), notice: 'Question deleted successfully' }
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
end
