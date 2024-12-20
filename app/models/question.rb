class Question < ApplicationRecord
  belongs_to :quiz
  has_many :attempted_questions #, dependent: :destroy
  has_many :attempts, through: :attempted_questions
  # validates :content, :options, :correct_answer, presence: true
  after_update :notify_attempted_questions
  before_destroy :archive_unarchived_attributes
  private
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
