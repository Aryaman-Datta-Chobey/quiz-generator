module QuizzesHelper
  
  def generate_questions_with_openai(quiz, user)
    remaining_questions = quiz.number_of_questions
    questions_per_call = determine_batch_size(quiz.difficulty, quiz.detail_level,quiz.number_of_questions)
    openai_service = OpenaiService.new 
    all_questions = []
    total_input_tokens = 0
    total_output_tokens = 0
    while remaining_questions > 0
      batch_size = [questions_per_call, remaining_questions].min
      
      prompt = quiz.build_prompt(topic=quiz.topic,batch_size,difficulty=quiz.difficulty,detail_level=quiz.detail_level)
      begin
        response = openai_service.generate_response(prompt, 5000, "mixtral-8x7b-32768") #response returned , this is what is being allowed to raise the JSON.Parse error
        puts response.inspect
        content = response[:content]
        input_tokens = response[:input_tokens]
        output_tokens = response[:output_tokens]
        # Log token details
        Rails.logger.info("Input Tokens: #{input_tokens}, Output Tokens: #{output_tokens}, Avg Tokens/Question: #{output_tokens / batch_size}")
        total_input_tokens += input_tokens
        total_output_tokens += output_tokens
        parsed_response = JSON.parse(content) 
        unless parsed_response.present? && parsed_response["questions"].present? && parsed_response["questions"].is_a?(Array)  
            raise JSON::ParserError
        end
        parsed_response["questions"].each do |question|
          all_questions << {
                content: question["content"],
                options: question["options"],
                correct_answer: question["correct_answer"]
              }
            end
            #debugger
            remaining_questions -= batch_size
      rescue StandardError => e 
          Rails.logger.error("Question generation failed for batch size #{batch_size}: #{e.message}")
          break
      end
    end
  
    # return hash
    results = {
      success: all_questions.present?,
      generated_questions: all_questions,
      msg:  all_questions.count == quiz.number_of_questions ? "Quiz was successfully generated." : "Quiz has #{quiz.questions.count} questions instead of #{quiz.number_of_questions}"
    }
  end

  def determine_batch_size(difficulty, detail_level, number_of_questions)
    if difficulty == "easy" && detail_level != "high" || difficulty == "intermediate" && detail_level == "low"
      5
    elsif difficulty == "intermediate" && detail_level != "low" || difficulty == "hard"
      3
    else
      number_of_questions
    end
  end
end
