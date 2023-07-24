import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Private properties
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - IBOutlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(viwController: self)
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
    
    // метод показывает индикатор загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // метод показывает индикатор загрузки
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    // метод выводит данные вью модели на экран
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    //метод выводит сообщение о ошибке загрузки данных с сервера
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let errorModel = AlertModel(
            title: "Ошибка!",
            message: message,
            buttonText: "Попробовать ещё раз",
            buttonAction: {[weak self] in
                self?.presenter.restartGame()
            }
        )
        alertPresenter?.show(alertModel: errorModel)
    }
    
    // метод выводит финальную статистику
    func showFinalResults () {
        yesButton.isEnabled = true
        noButton.isEnabled = true
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: presenter.makeResultMessage(),
            buttonText: "Сыграть ещё раз",
            buttonAction: {[weak self] in
                self?.presenter.restartGame()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
    }
    
}



