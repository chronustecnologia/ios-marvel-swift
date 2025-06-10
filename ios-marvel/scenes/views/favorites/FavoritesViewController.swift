//
//  FavoritesViewController.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import UIKit

class FavoritesViewController: UIViewController {
    private let tableView = UITableView()
    private let emptyStateView = EmptyStateView()
    
    private let viewModel = FavoriteCharactersViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorites()
    }
    
    private func setupUI() {
        title = "Favorites"
        view.backgroundColor = .systemBackground
        
        // Empty State View
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Enable swipe to delete
        tableView.allowsSelectionDuringEditing = false
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func showEmptyState() {
        emptyStateView.configure(
            image: UIImage(systemName: "star.slash"),
            title: "No Favorites Yet",
            message: "Add characters to your favorites and they will appear here",
            buttonTitle: nil,
            action: nil
        )
        
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }
    
    private func updateUI() {
        if viewModel.isEmpty {
            showEmptyState()
        } else {
            emptyStateView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfFavorites
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseIdentifier, for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        
        let character = viewModel.character(at: indexPath.row)
        cell.configure(with: character)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let character = viewModel.character(at: indexPath.row)
        let detailVC = CharacterDetailViewController(character: character)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            _ = viewModel.removeFromFavorites(at: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
}

extension FavoritesViewController: FavoriteCharactersViewModelDelegate {
    func didUpdateFavorites() {
        DispatchQueue.main.async { [weak self] in
            self?.updateUI()
        }
    }
}
