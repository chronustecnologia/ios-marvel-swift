//
//  CharacterDetailViewModelDelegate.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import Foundation
import UIKit

protocol CharacterDetailViewModelDelegate: AnyObject {
    func didChangeFavoriteStatus()
}

class CharacterDetailViewModel {
    private let favoriteService: FavoriteServiceProtocol
    let character: Character
    weak var delegate: CharacterDetailViewModelDelegate?
    
    init(character: Character, favoriteService: FavoriteServiceProtocol = FavoriteService()) {
        self.character = character
        self.favoriteService = favoriteService
    }
    
    var name: String {
        return character.name
    }
    
    var description: String {
        return character.description.isEmpty ? "No description available" : character.description
    }
    
    var imageURL: URL? {
        return character.imageURL
    }
    
    var isFavorite: Bool {
        return favoriteService.isFavorite(character.id)
    }
    
    func toggleFavorite() -> Bool {
        let result = favoriteService.isFavorite(character.id) ? 
                    favoriteService.removeFromFavorites(character.id) :
                    favoriteService.addToFavorites(character)
        
        if result {
            delegate?.didChangeFavoriteStatus()
        }
        
        return result
    }
    
    func shareImage(image: UIImage, from viewController: UIViewController) {
        let items: [Any] = [image, "Check out this Marvel character: \(character.name)"]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        viewController.present(activityViewController, animated: true)
    }
}
