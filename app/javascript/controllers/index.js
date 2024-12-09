// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import QuizEditorController from "./quiz_editor_controller"
application.register("quiz-editor", QuizEditorController)
eagerLoadControllersFrom("controllers", application)
