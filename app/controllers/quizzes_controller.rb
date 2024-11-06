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
      @quiz = Quiz.find(params[:id])
      session[:quiz_start_time] = Time.current #for study_duration calculation
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
    
    # action to compute score and study_duration after user submits quiz (as a form)
    def submit
      @quiz = Quiz.find(params[:id])
      user_answers = params[:answers]
      score = 0
    
      @quiz.questions.each do |question| #simplified computation for iter 1 , may have to change for new question types in future
        correct = question.correct_answer
        if user_answers[question.id.to_s] == correct
          score += 1
        end
      end
    
      # Calculate duration
      start_time = session.delete(:quiz_start_time)
      duration = Time.current - start_time if start_time
      
      @quiz.update(score: score, duration: duration) 
      flash[:notice] = "You scored #{score} out of #{quiz.questions.count}. Time taken: #{duration.to_i} seconds."
      redirect_to quiz_path(@quiz) # displaying in same view for iter 1 , may consider creating seperate results route in the future

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
