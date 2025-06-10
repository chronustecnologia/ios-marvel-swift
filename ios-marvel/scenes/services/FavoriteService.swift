//
//  FavoriteServiceProtocol.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//


import Foundation

protocol FavoriteServiceProtocol {
    func getFavorites() -> [Character]
    func addToFavorites(_ character: Character) -> Bool
    func removeFromFavorites(_ characterId: Int) -> Bool
    func isFavorite(_ characterId: Int) -> Bool
}

class FavoriteService: FavoriteServiceProtocol {
    private let userDefaults: UserDefaults
    private let favoritesKey = "FavoriteCharacters"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getFavorites() -> [Character] {
        guard let data = userDefaults.data(forKey: favoritesKey) else {
            return []
        }
        
        guard let favorites = try? JSONDecoder().decode([Character].self, from: data) else {
            return []
        }
        
        return favorites
    }
    
    func addToFavorites(_ character: Character) -> Bool {
        var favorites = getFavorites()
        
        // Check if character is already in favorites
        if favorites.contains(where: { $0.id == character.id }) {
            return false
        }
        
        favorites.append(character)
        
        guard let data = try? JSONEncoder().encode(favorites) else {
            return false
        }
        
        userDefaults.set(data, forKey: favoritesKey)
        return true
    }
    
    func removeFromFavorites(_ characterId: Int) -> Bool {
        var favorites = getFavorites()
        
        guard let index = favorites.firstIndex(where: { $0.id == characterId }) else {
            return false
        }
        
        favorites.remove(at: index)
        
        guard let data = try? JSONEncoder().encode(favorites) else {
            return false
        }
        
        userDefaults.set(data, forKey: favoritesKey)
        return true
    }
    
    func isFavorite(_ characterId: Int) -> Bool {
        let favorites = getFavorites()
        return favorites.contains(where: { $0.id == characterId })
    }
}