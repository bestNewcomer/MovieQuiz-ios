
import UIKit

final class MovieQuizPresenter {
    private var currentQuestionIndex = 0
    let questionsAmount: Int = 10
    
    // метод проверяет последний ли это вопрос квиза
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // метод обнуляет счетчик вопросов
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    // метод увеличивает счетчик вопроса
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    
    // метод конвертирует моковые данные во вью модель
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel (
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)")
    }
    
}
