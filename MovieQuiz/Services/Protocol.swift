import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
}

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}

protocol StatisticServiceProtocol {
    var totalAccuracy: Double {get}
    var gamesCount: Int {get}
    var bestGame: GameRecord? {get}
    
    func store(correct:Int, total: Int)
}

protocol AlertPresenterProtocol {
    func show(alertModel: AlertModel)
}

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
