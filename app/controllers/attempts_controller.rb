class AttemptsController < ApplicationController
  def new
    @quiz = Quiz.find(params[:quiz_id])
    @attempt = @quiz.attempts.build
    session[:quiz_start_time] = Time.now.to_f # Start time for calculating study_duration
  end

  def create
    @quiz = Quiz.find(params[:quiz_id])
  
    # Calculate duration and attempt date
    start_time = session.delete(:quiz_start_time).to_f
    duration = (Time.now.to_f - start_time).to_i if start_time
    attempt_date = Date.today
  
    # Create the attempt with initial values (score=0 for now)
    @attempt = @quiz.attempts.create!(
      time_taken: duration,
      attempt_date: attempt_date,
      score: 0 # Initial score; will update later
    )
  
    # Calculate score and create AttemptedQuestions
    score = 0
    params[:attempt][:attempted_questions_attributes].each do |_, answer_data|
      question_id = answer_data[:question_id].to_i
      user_answer = answer_data[:user_answer]
  
      question = @quiz.questions.find(question_id)
      correct = user_answer == question.correct_answer
      score += 1 if correct
  
      # Create AttemptedQuestion immediately
      @attempt.attempted_questions.create!(
        question_id: question_id,
        user_answer: user_answer,
        correct: correct
      )
    end
  
    # Update the attempt with the final score
    @attempt.update!(score: score)
  
    # Handle success or failure
    flash[:notice] = "You scored #{score} out of #{@quiz.questions.count}. Time taken: #{duration} seconds."
    redirect_to quiz_attempt_path(@quiz, @attempt)
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = "There was an error submitting your attempt: #{e.message}"
    render :new
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
