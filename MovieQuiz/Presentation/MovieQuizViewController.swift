import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Private properties
    private let presenter = MovieQuizPresenter()
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - IBOutlet
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        imageView.layer.cornerRadius = 20
        loadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(viwController: self)
        statisticService = StatisticService()
        questionFactory?.requestNextQuestion()
        questionFactory?.loadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - Action
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.responseProcessing (answer:false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.responseProcessing (answer:true)
    }
    
    // MARK: - Private function
    
    // метод показывает/убирает индикатор загрузки
    private func loadingIndicator() {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
    }
    

    // метод выводит данные вью модели на экран
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // метод выводит сообщение со статистикой
    private func makeResultMessage () -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("Ошибка")
            return ""
        }
        let resultMessage = """
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
        Рекорд: \(bestGame.correct)/\(bestGame.total)
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        return resultMessage
    }
    
    // метод показывает финальную статистику
    private func showFinalResults () {
        statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть ещё раз",
            buttonAction: {[weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // метод меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers+=1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else {return}
            
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    // метод содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showFinalResults()
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    //метод выводит сообщение о ошибке загрузки данных с сервера
    private func showNetworkError(message: String) {
        activityIndicator.startAnimating()
        let errorModel = AlertModel(
            title: "Ошибка!",
            message: message,
            buttonText: "Попробовать ещё раз",
            buttonAction: {[weak self] in
                self?.presenter.resetQuestionIndex()
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(alertModel: errorModel)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        activityIndicator.stopAnimating()
        guard let question = question else {
            return
        }
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // метод сообщает об успешной загрузки данных
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    // метод сообщает об ошибке загрузки данных
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}



