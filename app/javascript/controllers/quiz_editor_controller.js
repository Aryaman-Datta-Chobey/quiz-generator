import { Controller } from "@hotwired/stimulus" 

export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus!", this.element)
   }
  static targets = ["quizProperties", "questions"]
  
  toggleQuizProperties(event) {  // connects to button for collapsing/expanding form in Section 1 of app/views/quizzes/edit.html.erb
    console.log("Toggled", event.target);
    this.quizPropertiesTarget.classList.toggle("collapsed");
  
    const isCollapsed = this.quizPropertiesTarget.classList.contains("collapsed");
    const buttonText = isCollapsed
      ? "Edit Quiz Properties"
      : "Collapse Quiz Properties";
    event.target.innerText = buttonText;
    console.log("Quiz properties are now", isCollapsed ? "collapsed" : "expanded");
  }
  

  handleAnswerCardClick(event) { // connects to answer card rendered by  app/views/questions/_answer_card.html.erb
    console.log("Card clicked", event.target);
    const card = event.target.closest(".answer-card"); // Ensure we get the .answer-card element
    if (!card) return;

    const currentQuestion = card.closest(".question-fields");
    if (event.target.type === "text") return; // Avoid selecting as correct answer if clicked inside the text field

    // Deselect all cards
    currentQuestion.querySelectorAll(".answer-card").forEach((c) => {
        c.classList.remove("selected");
    });

    // Select the clicked card
    card.classList.add("selected");

    // Toggle visibility of "Remove Option" buttons
    currentQuestion.querySelectorAll(".answer-card").forEach((c) => {
        const removeButton = c.querySelector(".btn.text-danger");
        if (removeButton) {
            removeButton.style.visibility = c.classList.contains("selected") ? "hidden" : "visible";
        }
    });

    // Update the hidden correct-answer field
    const correctAnswerField = currentQuestion.querySelector(".correct-answer");
    correctAnswerField.value = card.dataset.answer;
}

  

  handleAnswerCardChange(event) { // connects to answer card rendered by  app/views/questions/_answer_card.html.erb
    console.log("Card changed", event.target)
    const answerCard = event.target.closest(".answer-card")
    const newAnswerText = event.target.value.trim()

    // Update the card's data-answer attribute
    answerCard.dataset.answer = newAnswerText

    // Update the correct-answer field if this card is selected
    const currentQuestion = event.target.closest(".question-fields")
    const correctAnswerField = currentQuestion.querySelector(".correct-answer")
    if (answerCard.classList.contains("selected")) {
      correctAnswerField.value = newAnswerText // modifies contents of hidden correct_answer form field rendered by app/views/questions/_question_form.html.erb
    }
    // Update the hidden options field
    this.updateHiddenOptions(currentQuestion)
  }

  updateHiddenOptions(currentQuestion){ // modifies contents of hidden options form field rendered by app/views/questions/_question_form.html.erb
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

  addOption(event) { // connects to answer card rendered by  app/views/questions/_answer_card.html.erb
    console.log("Add option clicked", event.target)
    const currentQuestion = event.target.closest(".question-fields");
    console.log("current Question", currentQuestion)
    const answerCardsContainer = currentQuestion.querySelector(".answer-cards");
    console.log("answer Cards container",answerCardsContainer)

    // Create a new answer card
    const newCard = document.createElement("div");
    newCard.classList.add("col-md-6");
    newCard.innerHTML = `
      <div class="card p-3 shadow-sm answer-card" data-answer="">
        <input type="text" class="form-control new-options" placeholder="Enter answer option..." 
          data-action="change->quiz-editor#handleAnswerCardChange">
        <button type="button" class="btn btn-link text-danger mt-2" 
          data-action="click->quiz-editor#removeOption">Remove Option</button>
      </div>
    `;
    answerCardsContainer.appendChild(newCard);

    // Update the hidden options field
    this.updateHiddenOptions(currentQuestion);
  }
  removeOption(event) { // (BROKEN) connects to answer card rendered by  app/views/questions/_answer_card.html.erb ()
    //Bug: When clicked , option is removed from DOM but hidden options field is not updated to remove the option from question.options upon save
    console.log("remove option clicked", event.target)
    // Step 1: Prevent default behavior and stop event propagation
    event.preventDefault(); // Stop it from triggering form submission
    event.stopPropagation(); // Stop removing option from triggering answerCard click
    
    const option = event.target.closest(".col-md-6");
    console.log("option found: ", option)
    const optionText = option.querySelector('.new-options')?.value.trim(); // Get the card's option text
    console.log("optionText found: ", optionText)
    const currentQuestion = option.closest(".question-fields"); // Parent question block
    console.log("currentQuestion found: ", currentQuestion)
    const optionsField = currentQuestion.querySelector(".options-field");//option.closest('input[name="options"]'); // Hidden options field
    console.log("optionsField found: ", optionsField)

    option.remove(); // remove option's answer card from client side UI

    // Remove the selected option's text from the hidden options field at client side questions form
    let options = JSON.parse(optionsField.value || '[]');
    console.log("options parsed: ", options , " from value:", optionsField.value )
    options = options.filter(option => option !== optionText); 
    console.log("options after option removed: ", options , " new field value:", JSON.stringify(options) )
    optionsField.value = JSON.stringify(options);
}
  

}