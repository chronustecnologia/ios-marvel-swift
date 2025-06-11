//
//  FavoriteServiceTests.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//


import XCTest
@testable import ios_marvel

class FavoriteServiceTests: XCTestCase {
    
    var mockUserDefaults: MockUserDefaults!
    var service: FavoriteService!
    var testCharacter: Character!
    
    override func setUp() {
        super.setUp()
        mockUserDefaults = MockUserDefaults()
        service = FavoriteService(userDefaults: mockUserDefaults)
        
        testCharacter = Character(
            id: 1,
            name: "Spider-Man",
            description: "Bitten by a radioactive spider",
            thumbnail: Thumbnail(path: "http://example.com/image", extension: "jpg"),
            resourceURI: "http://example.com/character/1"
        )
    }
    
    override func tearDown() {
        mockUserDefaults = nil
        service = nil
        testCharacter = nil
        super.tearDown()
    }
    
    func testGetFavorites_EmptyByDefault() {
        // When
        let favorites = service.getFavorites()
        
        // Then
        XCTAssertTrue(favorites.isEmpty)
    }
    
    func testAddToFavorites_Success() {
        // When
        let result = service.addToFavorites(testCharacter)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertEqual(service.getFavorites().count, 1)
        XCTAssertEqual(service.getFavorites().first?.id, testCharacter.id)
    }
    
    func testAddToFavorites_DuplicateCharacter() {
        // Given
        _ = service.addToFavorites(testCharacter)
        
        // When
        let result = service.addToFavorites(testCharacter)
        
        // Then
        XCTAssertFalse(result) 
        XCTAssertEqual(service.getFavorites().count, 1)
    }
    
    func testRemoveFromFavorites_Success() {
        // Given
        _ = service.addToFavorites(testCharacter)
        
        // When
        let result = service.removeFromFavorites(testCharacter.id)
        
        // Then
        XCTAssertTrue(result)
        XCTAssertTrue(service.getFavorites().isEmpty)
    }
    
    func testRemoveFromFavorites_NotFound() {
        // When
        let result = service.removeFromFavorites(999)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func testIsFavorite() {
        // Given
        _ = service.addToFavorites(testCharacter)
        
        // When & Then
        XCTAssertTrue(service.isFavorite(testCharacter.id))
        XCTAssertFalse(service.isFavorite(999))
    }
}
