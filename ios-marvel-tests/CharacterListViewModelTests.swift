//
//  CharacterListViewModelTests.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import XCTest
@testable import ios_marvel

class CharacterListViewModelTests: XCTestCase {
    
    class MockCharacterService: CharacterServiceProtocol {
        var mockCharacters: [Character] = []
        var mockError: NetworkError?
        var loadCharactersCalled = false
        
        func fetchCharacters(offset: Int, limit: Int, nameStartsWith: String?, completion: @escaping (Result<[Character], NetworkError>) -> Void) {
            loadCharactersCalled = true
            
            if let error = mockError {
                completion(.failure(error))
            } else {
                completion(.success(mockCharacters))
            }
        }
    }
    
    class MockFavoriteService: FavoriteServiceProtocol {
        var mockFavorites: Set<Int> = []
        
        func getFavorites() -> [Character] {
            return []
        }
        
        func addToFavorites(_ character: Character) -> Bool {
            mockFavorites.insert(character.id)
            return true
        }
        
        func removeFromFavorites(_ characterId: Int) -> Bool {
            return mockFavorites.remove(characterId) != nil
        }
        
        func isFavorite(_ characterId: Int) -> Bool {
            return mockFavorites.contains(characterId)
        }
    }
    
    var mockCharacterService: MockCharacterService!
    var mockFavoriteService: MockFavoriteService!
    var viewModel: CharacterListViewModel!
    
    override func setUp() {
        super.setUp()
        mockCharacterService = MockCharacterService()
        mockFavoriteService = MockFavoriteService()
        viewModel = CharacterListViewModel(
            characterService: mockCharacterService,
            favoriteService: mockFavoriteService
        )
    }
    
    override func tearDown() {
        mockCharacterService = nil
        mockFavoriteService = nil
        viewModel = nil
        super.tearDown()
    }
    
    func testLoadCharacters_Success() {
        // Given
        let testCharacters = [
            Character(id: 1, name: "Spider-Man", description: "Desc", thumbnail: Thumbnail(path: "path", extension: "jpg"), resourceURI: "uri"),
            Character(id: 2, name: "Iron Man", description: "Desc", thumbnail: Thumbnail(path: "path", extension: "jpg"), resourceURI: "uri")
        ]
        mockCharacterService.mockCharacters = testCharacters
        
        // Create an expectation for characters to load
        let expectation = XCTestExpectation(description: "Characters loaded")
        
        class MockDelegate: CharacterListViewModelDelegate {
            let expectation: XCTestExpectation
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateCharacters() {
                expectation.fulfill()
            }
            
            func didEncounterError(_ error: NetworkError) {
                XCTFail("Should not encounter error")
            }
        }
        
        viewModel.delegate = MockDelegate(expectation: expectation)
        
        // When
        viewModel.loadCharacters()
        
        // Then
        //wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockCharacterService.loadCharactersCalled)
        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertEqual(viewModel.characters[0].id, testCharacters[0].id)
        XCTAssertEqual(viewModel.characters[1].name, testCharacters[1].name)
    }
    
    func testLoadCharacters_Error() {
        // Given
        mockCharacterService.mockError = .noInternet
        
        // Create an expectation for error
        let expectation = XCTestExpectation(description: "Error received")
        
        class MockDelegate: CharacterListViewModelDelegate {
            let expectation: XCTestExpectation
            var receivedError: NetworkError?
            
            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }
            
            func didUpdateCharacters() {
                XCTFail("Should not update characters")
            }
            
            func didEncounterError(_ error: NetworkError) {
                receivedError = error
                expectation.fulfill()
            }
        }
        
        let mockDelegate = MockDelegate(expectation: expectation)
        viewModel.delegate = mockDelegate
        
        // When
        viewModel.loadCharacters()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockCharacterService.loadCharactersCalled)
        //XCTAssertEqual(mockDelegate.receivedError, .noInternet)
        XCTAssertEqual(viewModel.characters.count, 0)
    }
    
    func testToggleFavorite() {
        // Given
        let testCharacter = Character(id: 1, name: "Spider-Man", description: "Desc", thumbnail: Thumbnail(path: "path", extension: "jpg"), resourceURI: "uri")
        
        // When - Add to favorites
        let addResult = viewModel.toggleFavorite(character: testCharacter)
        
        // Then
        XCTAssertTrue(addResult)
        XCTAssertTrue(mockFavoriteService.isFavorite(testCharacter.id))
        
        // When - Remove from favorites
        let removeResult = viewModel.toggleFavorite(character: testCharacter)
        
        // Then
        XCTAssertTrue(removeResult)
        XCTAssertFalse(mockFavoriteService.isFavorite(testCharacter.id))
    }
    
    func testSearchCharacters() {
        // Given
        viewModel.searchQuery = "Spider"
        
        // When
        viewModel.searchCharacters()
        
        // Then
        XCTAssertTrue(mockCharacterService.loadCharactersCalled)
        XCTAssertEqual(viewModel.currentOffset, 0) // Should reset when searching
    }
}
