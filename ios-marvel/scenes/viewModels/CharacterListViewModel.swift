//
//  CharacterListViewModelDelegate.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import Foundation

protocol CharacterListViewModelDelegate: AnyObject {
    func didUpdateCharacters()
    func didEncounterError(_ error: NetworkError)
}

class CharacterListViewModel {
    private let characterService: CharacterServiceProtocol
    private let favoriteService: FavoriteServiceProtocol
    weak var delegate: CharacterListViewModelDelegate?
    
    var characters: [Character] = []
    var filteredCharacters: [Character] = []
    var isLoading = false
    var currentOffset = 0
    var searchQuery: String = "" {
        didSet {
            searchCharacters()
        }
    }
    
    init(characterService: CharacterServiceProtocol = CharacterService(),
         favoriteService: FavoriteServiceProtocol = FavoriteService()) {
        self.characterService = characterService
        self.favoriteService = favoriteService
    }
    
    func loadCharacters(loadMore: Bool = false) {
        if isLoading {
            return
        }
        
        isLoading = true
        
        if loadMore {
            currentOffset += 20
        } else {
            currentOffset = 0
            characters = []
        }
        
        characterService.fetchCharacters(
            offset: currentOffset,
            limit: 20,
            nameStartsWith: searchQuery.isEmpty ? nil : searchQuery
        ) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let newCharacters):
                if loadMore {
                    self.characters.append(contentsOf: newCharacters)
                } else {
                    self.characters = newCharacters
                }
                self.filteredCharacters = self.characters
                self.delegate?.didUpdateCharacters()
                
            case .failure(let error):
                self.delegate?.didEncounterError(error)
            }
        }
    }
    
    func searchCharacters() {
        guard !searchQuery.isEmpty else {
            filteredCharacters = characters
            delegate?.didUpdateCharacters()
            return
        }
        
        currentOffset = 0
        loadCharacters()
    }
    
    func isFavorite(_ characterId: Int) -> Bool {
        return favoriteService.isFavorite(characterId)
    }
    
    func toggleFavorite(character: Character) -> Bool {
        if isFavorite(character.id) {
            return favoriteService.removeFromFavorites(character.id)
        } else {
            return favoriteService.addToFavorites(character)
        }
    }
    
    func character(at index: Int) -> Character {
        return filteredCharacters[index]
    }
    
    var numberOfCharacters: Int {
        return filteredCharacters.count
    }
}
