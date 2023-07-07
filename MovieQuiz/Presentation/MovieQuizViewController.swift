import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
// MARK: - Action
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        responseProcessing (answer:false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        responseProcessing (answer:true)
    }
    
// MARK: - Private function
    // метод обрабатывает ответ
    private func responseProcessing (answer:Bool){
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer:Bool = answer
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // метод конвертирует моковые данные во вью модель
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel (
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)")
        return questionStep
    }
    
    // метод выводит данные вью модели на экран
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // метод содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showFinalResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    // метод показывает финальную статистику
    private func showFinalResults () {
        statisticService?.store(correct: correctAnswers, total: questionsAmount)
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть ещё раз",
            buttonAction: {[weak self] in
                guard let self = self else {return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    // метод выводит сообщение со статистикой
    private func makeResultMessage () -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("Ошибка")
            return ""
        }
        """
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Ваш результат: \(correctAnswers)\\\(questionsAmount)
        Рекорд: \(bestGame.correct)\\\(bestGame.total)
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        let resultMessage = ["Количество сыгранных квизов: \(statisticService.gamesCount)", "Ваш результат: \(correctAnswers)\\\(questionsAmount)", "Рекорд: \(bestGame.correct)\\\(bestGame.total)", "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"].joined(separator: "/n")
        return resultMessage
    }
    // метод меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers+=1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        // запускаем задачу через 0.5 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else {return}
            
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(viwController: self)
        statisticService = StatisticService()
        
        questionFactory?.requestNextQuestion()
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
               self?.show(quiz: viewModel)
        }
    }
}

