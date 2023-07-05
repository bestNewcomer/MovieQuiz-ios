import UIKit
class AlertPresenter: UIViewController, QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        <#code#>
    }
    
    private var questionFactory: QuestionFactoryProtocol?
    
    // метод показывает результаты раунда квиза
    func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) {[weak self] _ in
            guard let self = self else {return}
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            questionFactory?.requestNextQuestion()
        }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        
    }
    
}
