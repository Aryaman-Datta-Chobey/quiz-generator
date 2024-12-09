import { Controller } from "@hotwired/stimulus" //import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus!", this.element)
   }
  static targets = ["quizProperties", "questions"]

  toggleQuizProperties(event) {
    console.log("Toggled", event.target);
    this.quizPropertiesTarget.classList.toggle("collapsed");
  
    const isCollapsed = this.quizPropertiesTarget.classList.contains("collapsed");
    const buttonText = isCollapsed
      ? "Edit Quiz Properties"
      : "Collapse Quiz Properties";
    event.target.innerText = buttonText;
    console.log("Quiz properties are now", isCollapsed ? "collapsed" : "expanded");
  }
  

  handleAnswerCardClick(event) {
    console.log("Card clicked", event.target)
    const card = event.target.closest(".answer-card") // Ensure we get the .answer-card element
    if (!card) return
  
    const currentQuestion = card.closest(".question-fields")
  
    // Deselect all cards
    currentQuestion.querySelectorAll(".answer-card").forEach(c =>
      c.classList.remove("selected")
    )
  
    // Select the clicked card
    card.classList.add("selected")
  
    // Update the hidden correct-answer field
    const correctAnswerField = currentQuestion.querySelector(".correct-answer")
    correctAnswerField.value = card.dataset.answer
  }
  

  handleAnswerCardChange(event) {
    console.log("Card changed", event.target)
    const answerCard = event.target.closest(".answer-card")
    const newAnswerText = event.target.value.trim()

    // Update the card's data-answer attribute
    answerCard.dataset.answer = newAnswerText

    // Update the correct-answer field if this card is selected
    const currentQuestion = event.target.closest(".question-fields")
    const correctAnswerField = currentQuestion.querySelector(".correct-answer")
    if (answerCard.classList.contains("selected")) {
      correctAnswerField.value = newAnswerText
    }

    // Update the hidden options field
    this.updateHiddenOptions(currentQuestion)
  }

  updateHiddenOptions(currentQuestion) {
    // Get all answer option values from the cards
    const options = Array.from(currentQuestion.querySelectorAll('.new-options'))
      .map(input => input.value.trim()) // Get the value of each option input field

    // Find the hidden field for options in the same question section
    const hiddenOptionsField = currentQuestion.querySelector('.new-op')
    console.log("hidden options field value before: ", hiddenOptionsField.value)

    // Update the hidden options field with the new comma-separated values
    hiddenOptionsField.value = JSON.stringify(options);
    console.log("hidden options field value after: ", hiddenOptionsField.value)
  }
}