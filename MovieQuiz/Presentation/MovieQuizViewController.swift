import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
   
    // MARK: - Private properties
    private let presenter = MovieQuizPresenter()
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - IBOutlet
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        imageView.layer.cornerRadius = 20
        loadingIndicator()
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(viwController: self)
        statisticService = StatisticService()
        presenter.questionFactory?.requestNextQuestion()
        presenter.questionFactory?.loadData()
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
    func loadingIndicator() {
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
    }
    
    // метод показывает финальную статистику
    func showFinalResults () {
        statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        yesButton.isEnabled = true
        noButton.isEnabled = true
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть ещё раз",
            buttonAction: {[weak self] in
                self?.presenter.resetQuestionIndex()
                self?.presenter.correctAnswers = 0
                self?.presenter.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    // метод выводит данные вью модели на экран
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // метод выводит сообщение со статистикой
    func makeResultMessage () -> String {
        
        guard let statisticService = statisticService, let bestGame = statisticService.bestGame else {
            assertionFailure("Ошибка")
            return ""
        }
        let resultMessage = """
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
        Рекорд: \(bestGame.correct)/\(bestGame.total)
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        return resultMessage
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
                self?.presenter.correctAnswers = 0
                self?.presenter.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(alertModel: errorModel)
    }
    
    // метод меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            presenter.correctAnswers+=1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else {return}
            
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.presenter.showNextQuestionOrResults()
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    // метод сообщает об успешной загрузки данных
    func didLoadDataFromServer() {
        presenter.questionFactory?.requestNextQuestion()
    }
    
    // метод сообщает об ошибке загрузки данных
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}



