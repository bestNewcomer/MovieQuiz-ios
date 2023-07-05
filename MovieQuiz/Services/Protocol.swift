import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
}

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}

protocol StatisticServiceProtocol {
    var totalAccuracy: Double {get}
    var gamesCount: Int {get}
    var bestGame: BestGame? {get}
    
    func store(correct:Int, total: Int)
}

