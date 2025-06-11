//
//  CharacterListViewModelDelegate.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import Foundation
import Combine

protocol CharacterListViewModelDelegate: AnyObject {
    func didUpdateCharacters()
    func didEncounterError(_ error: NetworkError)
}

final class CharacterListViewModel {
    private let characterService: CharacterServiceProtocol
    private let favoriteService: FavoriteServiceProtocol
    
    weak var delegate: CharacterListViewModelDelegate?
    
    private let defaultOffset = 20
    
    private var searchSubject = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()
    
    var characters: [Character] = []
    var filteredCharacters: [Character] = []
    var isLoading = false
    var currentOffset = 0
    var hasMoreData = true
    
    var searchQuery: String {
        get { searchSubject.value }
        set { searchSubject.send(newValue) }
    }
    
    init(characterService: CharacterServiceProtocol = CharacterService(),
         favoriteService: FavoriteServiceProtocol = FavoriteService()) {
        self.characterService = characterService
        self.favoriteService = favoriteService
        self.setupBindings()
    }
    
    func loadCharacters(loadMore: Bool = false) {
        if isLoading || (loadMore && !hasMoreData) {
            return
        }
        
        isLoading = true
        
        if loadMore {
            currentOffset += defaultOffset
        } else {
            currentOffset = 0
            characters = []
            hasMoreData = true
        }
        
        let searchParam = searchQuery.isEmpty ? nil : searchQuery
        
        characterService.fetchCharacters(
            offset: currentOffset,
            limit: defaultOffset,
            nameStartsWith: searchParam
        ) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let newCharacters):
                if newCharacters.isEmpty {
                    self.hasMoreData = false
                    return
                }
                
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
    
    private func setupBindings() {
        searchSubject
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                
                self.currentOffset = 0
                if self.isLoading { return }
                
                self.loadCharacters()
            }
            .store(in: &cancellables)
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
