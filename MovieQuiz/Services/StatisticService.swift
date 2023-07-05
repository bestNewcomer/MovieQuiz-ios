import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    var totalAccuracy: Double {
        Double(correct) / Double(total) * 100
    }
    
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: BestGame? {
        get {
            guard
                let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let bestGame = try? decoder.decode(BestGame.self, from: data) else {
                assertionFailure("Ошибка")
                return nil
            }
            return bestGame
        }
        set {
            let data = try? encoder.encode(newValue)
            userDefaults.set(newValue, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    private let userDefaults: UserDefaults
    private let decoder:JSONDecoder
    private let encoder:JSONEncoder
    private let dateProvider:() -> Data
    
    init (
        userDefaults: UserDefaults = .standard,
        decoder:JSONDecoder = JSONDecoder(),
        encoder:JSONEncoder = JSONEncoder(),
        dateProvider: @escaping () -> Data = { Data() }
    ) {
        self.userDefaults = userDefaults
        self.decoder = decoder
        self.encoder = encoder
        self.dateProvider = dateProvider
    }
    
    func store(correct: Int, total: Int) {
        self.correct += correct
        self.total += total
        self.gamesCount += 1
        
        let date = dateProvider()
        let currentBestGame = BestGame(correct: correct, total: total, date: date)
       
        if let previosBestGame = bestGame {
            if currentBestGame > previosBestGame {
                bestGame = currentBestGame
            }
        } else {
            bestGame = currentBestGame
        }
    }
}
