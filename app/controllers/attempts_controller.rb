class AttemptsController < ApplicationController
  def new
    @quiz = Quiz.find(params[:quiz_id])
    @attempt = @quiz.attempts.build
    session[:quiz_start_time] = Time.now.to_f # Start time for calculating study_duration
  end

  def create
    @quiz = Quiz.find(params[:quiz_id])
    @attempt = @quiz.attempts.build(attempt_params)
    score = 0
  
    # Calculate score by comparing user answers to correct answers
    @quiz.questions.each do |question|
      # Find the corresponding answer from the form data
      user_answer_data = params.dig(:attempt, :attempted_questions_attributes).values.detect do |v|
        v[:question_id].to_i == question.id
      end
      user_answer = user_answer_data[:user_answer] if user_answer_data
  
      # Check if the answer is correct
      if user_answer == question.correct_answer
        score += 1
        @attempt.attempted_questions.build(question: question, user_answer: user_answer, correct: true)
      else
        @attempt.attempted_questions.build(question: question, user_answer: user_answer, correct: false)
      end
    end
  
    # Calculate duration
    start_time = session.delete(:quiz_start_time).to_f
    duration = (Time.now.to_f - start_time).to_i if start_time
  
    # Save attempt details
    @attempt.score = score
    @attempt.time_taken = duration
    @attempt.attempt_date = Date.today
  
    if @attempt.save
      flash[:notice] = "You scored #{score} out of #{@quiz.questions.count}. Time taken: #{duration} seconds."
      redirect_to quiz_attempt_path(@quiz, @attempt)
    else
      flash[:alert] = "There was an error submitting your attempt."
      render :new
    end
  end

  def show
    @attempt = Attempt.find(params[:id]) 
  @quiz = @attempt.quiz
  end

  private

  def attempt_params
    params.require(:attempt).permit(
      :attempt_date,
      attempted_questions_attributes: [:question_id, :user_answer, :correct]
    )
  end
  
end
