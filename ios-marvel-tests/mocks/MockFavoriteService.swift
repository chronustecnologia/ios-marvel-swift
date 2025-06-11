//
//  MockFavoriteService.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 11/06/25.
//

@testable import ios_marvel

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
