
import XCTest
@testable import MovieQuiz

class MoaviesLoaderTests: XCTestCase {
    
    //тест на проверку успешной загрузки данных
    func testSuccessLoading() throws {
        
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Ожидание загрузки")
        loader.loadMovies { result in
            
            // Then
            switch result {
            case.success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case.failure(_):
                XCTFail("Неожиданный сбой")
            }
        }
        waitForExpectations(timeout: 1)
        
    }
    
    //тест на проверку ошибки загрузки данных
    func testFailureLoading() throws {
        
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Ожидание загрузки")
        loader.loadMovies { result in
            
            // Then
            switch result {
            case.success(_):
                XCTFail("Неожиданный сбой")
            case.failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1)
        
    }
}



