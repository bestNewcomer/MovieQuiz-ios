import UIKit

final class MovieQuizViewController: UIViewController {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private let questionFactory: QuestionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        responseProcessing (answer:false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        responseProcessing (answer:true)
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
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
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            if let nextQuestion = questionFactory.requestNextQuestion(){
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                show(quiz: viewModel)
            }
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
    }
    
    // метод меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers+=1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
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
            
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
        }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // выводим информацию на экран для первого вопроса
        if let firstQuestion = self.questionFactory.requestNextQuestion() {
            self.currentQuestion = firstQuestion
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
    }
    
}

