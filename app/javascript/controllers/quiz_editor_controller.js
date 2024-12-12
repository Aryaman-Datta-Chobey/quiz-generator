import { Controller } from "@hotwired/stimulus" //import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    console.log("Hello, Stimulus!", this.element)
   }
  static targets = ["quizProperties", "questions","newq"]
  
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

  updateHiddenOptions(currentQuestion){
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

  addQuestion(event) {
    event.preventDefault();
  
    // Get the template and container for questions
    const template = document.querySelector("#new-question-template").innerHTML;
    console.log("template: ", template)
    const questionsContainer = this.questionsTarget;
  
    // Generate a unique index for the new question
    const newIndex = new Date().getTime(); // Use a timestamp to avoid collisions
    console.log("index:",newIndex)
    const newQuestionHTML = template.replace(/_attributes\]\[\d+\]/g, `_attributes][${newIndex}]`);
    console.log("NEW HTML:",newQuestionHTML)
    // Append the new question fields to the container
    questionsContainer.insertAdjacentHTML("beforeend", newQuestionHTML);
  }
  
  removeQuestion(event) {
    const question = event.target.closest(".question-fields");
    const questionId = question.dataset.id;  // Assuming each question has a data-id attribute
    const quizId = event.target.dataset.quizId;
    console.log("Quiz ID:", quizId);
    const url = `/quizzes/${quizId}/questions/remove_question/${questionId}`;
  
    fetch(url, { method: 'DELETE' })
      .then(() => {
        question.remove();  // Remove the question from the DOM after successful deletion
      })
      .catch((error) => {
        console.error("Error removing question:", error);
      });
  }

  addOption(event) {
    const questionFields = event.target.closest(".question-fields");
  
    // 1. Parse the data-options array and add a new option
    const optionsParagraph = questionFields.querySelector(".curr_options_json_array");
  
    // 2. Update the options paragraph content
    const newOptionsJSON = JSON.stringify(event.target.dataset.options); // Convert to JSON string
    optionsParagraph.textContent = `<%= @options_json_array= JSON.parse(${newOptionsJSON} || '[]') %>`;
  
    // Call updateHiddenOptions to sync the hidden field with updated options
    this.updateHiddenOptions(questionFields);
  
    // 3. Check and update the status field
    const statusField = questionFields.querySelector(".status");
    if (statusField.value === "unchanged") {
      statusField.value = "modified";
    }
  }

  removeOption(event) {
    const option = event.target.closest(".col-md-6");
    option.remove();
    const optionsParagraph = questionFields.querySelector(".curr_options_json_array");
    const newOptionsJSON = JSON.stringify(event.target.dataset.options); // Convert to JSON string
    optionsParagraph.textContent = `<%= @options_json_array= JSON.parse(${newOptionsJSON} || '[]') %>`;
    this.updateHiddenOptions(questionFields);
    const statusField = questionFields.querySelector(".status");
    if (statusField.value === "unchanged") {
      statusField.value = "modified";
    }
  }
}