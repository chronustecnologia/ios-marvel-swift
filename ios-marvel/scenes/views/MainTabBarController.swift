//
//  MainTabBarController.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
    }
    
    private func setupViewControllers() {
        let charactersVC = CharactersViewController()
        let charactersNav = UINavigationController(rootViewController: charactersVC)
        charactersNav.tabBarItem = UITabBarItem(title: "Personagens Marvel", image: UIImage(systemName: "person.3"), tag: 0)
        
        let favoritesVC = FavoritesViewController()
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(title: "Favoritos", image: UIImage(systemName: "star"), tag: 1)
        
        viewControllers = [charactersNav, favoritesNav]
    }
}
