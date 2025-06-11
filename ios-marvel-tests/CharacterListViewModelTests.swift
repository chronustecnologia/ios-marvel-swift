//
//  CharacterListViewModelTests.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import XCTest
@testable import ios_marvel

class CharacterListViewModelTests: XCTestCase {
    
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
        
        let mockDelegate = MockDelegate(expectation: expectation)
        viewModel.delegate = mockDelegate
        
        // When
        viewModel.loadCharacters()
        
        // Then
        XCTAssertTrue(mockCharacterService.loadCharactersCalled)
        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertEqual(viewModel.characters[0].id, testCharacters[0].id)
        XCTAssertEqual(viewModel.characters[1].name, testCharacters[1].name)
    }
    
    func testLoadCharacters_Error() {
        // Given
        mockCharacterService.mockError = .noInternet
        
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
        XCTAssertEqual(viewModel.characters.count, 0)
    }
    
    func testToggleFavorite() {
        // Given
        let testCharacter = Character(id: 1, name: "Spider-Man", description: "Desc", thumbnail: Thumbnail(path: "path", extension: "jpg"), resourceURI: "uri")
        
        let addResult = viewModel.toggleFavorite(character: testCharacter)
        
        // Then
        XCTAssertTrue(addResult)
        XCTAssertTrue(mockFavoriteService.isFavorite(testCharacter.id))
        
        // When
        let removeResult = viewModel.toggleFavorite(character: testCharacter)
        
        // Then
        XCTAssertTrue(removeResult)
        XCTAssertFalse(mockFavoriteService.isFavorite(testCharacter.id))
    }
}
