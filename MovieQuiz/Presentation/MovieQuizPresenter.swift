import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Private properties
    private var currentQuestionIndex = 0
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var correctAnswers = 0
    
    init (viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        questionFactory?.requestNextQuestion()
        viewController.showLoadingIndicator()
        statisticService = StatisticService()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    // метод сообщает об успешной загрузки данных
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    // метод сообщает об ошибке загрузки данных
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    // MARK: - Function
    
    
    // метод проверяет последний ли это вопрос квиза
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    // метод обнуляет счетчик вопросов
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
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
    
    // метод обрабатывает нажатия "Да/Нет"
    func responseProcessing (answer:Bool){
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = answer
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
    }
    
    // метод содержит логику перехода в один из сценариев
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.showFinalResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
        viewController?.yesButton.isEnabled = true
        viewController?.noButton.isEnabled = true
    }
    
    // метод меняет цвет рамки
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResults()
        }
        viewController?.yesButton.isEnabled = false
        viewController?.noButton.isEnabled = false
    }
    
    // метод выводит сообщение со статистикой
    func makeResultMessage () -> String {
        
        guard
            let statisticService = statisticService,
            let bestGame = statisticService.bestGame
        else {
            assertionFailure("Ошибка")
            return ""
        }
        let resultMessage = """
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Рекорд: \(bestGame.correct)/\(bestGame.total)
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
        
        return resultMessage
    }
    
}
