//
//  FavoriteCharactersViewModelDelegate.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//


import Foundation

protocol FavoriteCharactersViewModelDelegate: AnyObject {
    func didUpdateFavorites()
}

class FavoriteCharactersViewModel {
    private let favoriteService: FavoriteServiceProtocol
    weak var delegate: FavoriteCharactersViewModelDelegate?
    
    var favoriteCharacters: [Character] = []
    
    init(favoriteService: FavoriteServiceProtocol = FavoriteService()) {
        self.favoriteService = favoriteService
    }
    
    func loadFavorites() {
        favoriteCharacters = favoriteService.getFavorites()
        delegate?.didUpdateFavorites()
    }
    
    func removeFromFavorites(at index: Int) -> Bool {
        let characterId = favoriteCharacters[index].id
        let result = favoriteService.removeFromFavorites(characterId)
        
        if result {
            favoriteCharacters.remove(at: index)
            delegate?.didUpdateFavorites()
        }
        
        return result
    }
    
    func character(at index: Int) -> Character {
        return favoriteCharacters[index]
    }
    
    var numberOfFavorites: Int {
        return favoriteCharacters.count
    }
    
    var isEmpty: Bool {
        return favoriteCharacters.isEmpty
    }
}