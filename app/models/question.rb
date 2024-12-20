class Question < ApplicationRecord
  #Associations 
  belongs_to :quiz
  has_many :attempted_questions 
  has_many :attempts, through: :attempted_questions
  #call back actions for observer mechanism
  after_update :notify_attempted_questions
  before_destroy :archive_unarchived_attributes
  # Validations to handle LLM hallucinations gracefully
  before_create :validate_and_correct_attributes

  @@question_answer_instruction={ #description of Question-Answer pair to be generated in step 1
    low: {
      easy: "is a simple true or false , or a question that tests simple recall or identification of factual or conceptual information about the topic.",
      intermediate: "is a true or false , or a question tests the ability to recall, understand and connect 2 or more pieces of information about the topic.",
      hard: "tests the ability to recall, understand, apply and analyze or evaluate information about the topic when given a briefly detailed example or scenario."
    },
    medium: {
      easy: "tests simple recall and identification of factual, conceptual or procedural information about the topic.",
      intermediate: "tests the ability to recall, understand and apply information about the topic to a moderately detailed example or scenario.",
      hard: "tests the ability to recall, understand, apply and analyze or evaluate information about the topic when given a moderately detailed example or scenario."
    },
    high: {
      easy: "presents a specific instance, scenario, or example related to the topic in the stem of the question and tests the ability to identify the underlying concept, rule, or principle that explains this instance.",
      intermediate: "tests the ability to recall, understand and apply information about the topic to a highly detailed example or scenario.",
      hard: "tests the ability to recall, understand, apply and analyze or evaluate information about the topic when given a highly detailed example or scenario."
    }
  }

  @@distractor_instruction = { #description of distractors to be generated in step 2
    low: {
      easy: "1 plausible but incorrect option (distractor).",
      intermediate: "1 or 2 plausible but incorrect options (distractors) that are similar to the correct answer.",
      hard: "1 or 2 highly plausible but subtly incorrect options (distractors) that are very similar to the correct answer."
    },
    medium: {
      easy: "3 plausible but incorrect options (distractors).",
      intermediate: "3 or 4 plausible but incorrect options (distractors) that are similar to the correct answer.",
      hard: "4 incorrect options (distractors) of which most are highly plausible (in relation to the question) but subtly incorrect (in relation to the topic info tested) and very similar to the correct answer."
    },
    high: {
      easy: "4 plausible but incorrect options (distractors).",
      intermediate: "4 or 5 plausible but incorrect options (distractors) that are similar to the correct answer.",
      hard: "5 incorrect options (distractors) of which most are highly plausible (in relation to the question) but subtly incorrect (in relation to the topic info tested) and very similar to the correct answer."
    }
  }
  def self.build_prompt(difficulty, detail_level)
    <<~INSTRUCTIONS
      1. Generate a question (and its correct answer) that #{@@question_answer_instruction[detail_level.to_sym][difficulty.to_sym]} Use github flavoured markdown for formatting any paragraphs lists, code chunks, tables etc.
      2. Create #{@@distractor_instruction[detail_level.to_sym][difficulty.to_sym]}. As with the question and answer each distractor should be  formatted using markdown.
    INSTRUCTIONS
  end
  private
#Dummy comment
  def validate_and_correct_attributes
    #Step 1. Helpful str vals in case LLM forgot to generate one or more atrr
    #Rails.logger.info("BEFORE: content: #{self.content}, correct_answer: #{self.correct_answer}")
    self.content = "No question stem was generated. Edit or delete this question." unless self.content.present?
    self.correct_answer = "No correct answer was generated. Edit or delete this question."  unless self.correct_answer.present?
    #Rails.logger.info("AFTER: content: #{self.content}, correct_answer: #{self.correct_answer}")
    if self.options.nil? 
      self.options ='["No options were generated. Edit or delete this question"]'
    else #Step 2. correct a problematic JSON array in options
      begin
        parsed_options = JSON.parse(self.options)
        #Rails.logger.info("parsed_options: #{parsed_options}")
        unless parsed_options.present? && parsed_options.is_a?(Array)  
          raise JSON::ParserError
        end
        cleaned_options=[]
        parsed_options.each do |opt|
          cleaned_options << opt.to_s if opt.present?
        end
        self.options=JSON.generate(cleaned_options)
      rescue JSON::ParserError
        original_options = self.options.to_s
        rescued_options=["Options were generated but not parseable. You can add these options manually by editing this question , or delete this question"]
        rescued_options << original_options # make the  single str representing broken options JSON array,  the 2nd element of this array
        self.options =  JSON.generate(rescued_options)
      end
    end
    #Step 3. Add correct answer to options if not already included
    unless self.options.include?(self.correct_answer)
      parsed_options=JSON.parse(self.options)
      parsed_options << self.correct_answer
      self.options=JSON.generate(parsed_options)
    end
  end
  

  def notify_attempted_questions
    attempted_questions.each { |aq| aq.archive_question_attributes(self,aq) }
  end

  def archive_unarchived_attributes
    attempted_questions.each do |aq|
      aq.archive_question_attributes_before_destruction(self, aq)
    end
  end
end
