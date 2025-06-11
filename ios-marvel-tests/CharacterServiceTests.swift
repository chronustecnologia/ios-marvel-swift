//
//  CharacterServiceTests.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//


import XCTest
@testable import ios_marvel

class CharacterServiceTests: XCTestCase {
        
    var mockAPIClient: MockAPIClient!
    var service: CharacterService!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        service = CharacterService(apiClient: mockAPIClient)
    }
    
    override func tearDown() {
        mockAPIClient = nil
        service = nil
        super.tearDown()
    }
    
    func testFetchCharacters_Success() {
        // Given
        let expectedCharacters = [
            Character(id: 1, name: "Spider-Man", description: "Bitten by a radioactive spider", thumbnail: Thumbnail(path: "http://example.com/image", extension: "jpg"), resourceURI: "http://example.com/character/1")
        ]
        
        let mockWrapper = CharacterDataWrapper(
            code: 200,
            status: "Ok",
            data: CharacterDataContainer(
                offset: 0,
                limit: 20,
                total: 1,
                count: 1,
                results: expectedCharacters
            )
        )
        
        mockAPIClient.mockResult = .success(mockWrapper)
        
        // When
        let expectation = XCTestExpectation(description: "Fetch characters")
        
        service.fetchCharacters { result in
            // Then
            switch result {
            case .success(let characters):
                XCTAssertEqual(characters.count, 1)
                XCTAssertEqual(characters[0].id, expectedCharacters[0].id)
                XCTAssertEqual(characters[0].name, expectedCharacters[0].name)
            case .failure:
                XCTFail("Expected success but got failure")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchCharacters_Failure() {
        // Given
        let expectedError = NetworkError.noInternet
        mockAPIClient.mockResult = .failure(expectedError)
        
        // When
        let expectation = XCTestExpectation(description: "Fetch characters failure")
        
        service.fetchCharacters { result in
            // Then
            switch result {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let error):
                switch (error, expectedError) {
                case (.invalidURL, .invalidURL),
                     (.noData, .noData),
                     (.decodingError, .decodingError),
                     (.noInternet, .noInternet):
                    break
                default:
                    XCTFail("Got error \(error), but expected \(expectedError)")
                }
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
