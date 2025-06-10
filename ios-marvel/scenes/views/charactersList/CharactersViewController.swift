//
//  CharactersViewController.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import UIKit

class CharactersViewController: UIViewController {
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let emptyStateView = EmptyStateView()
    
    private let viewModel = CharacterListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupSearchController()
        setupViewModel()
        
        loadCharacters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupUI() {
        title = "Marvel Characters"
        view.backgroundColor = .systemBackground
        
        // Activity Indicator
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // Empty State View
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        emptyStateView.isHidden = true
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
        
        tableView.register(CharacterCell.self, forCellReuseIdentifier: CharacterCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Characters"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func loadCharacters() {
        activityIndicator.startAnimating()
        viewModel.loadCharacters()
    }
    
    @objc private func refreshData() {
        viewModel.loadCharacters()
    }
    
    private func showErrorState(with message: String) {
        emptyStateView.configure(
            image: UIImage(systemName: "exclamationmark.triangle"),
            title: "Oops!",
            message: message,
            buttonTitle: "Try Again"
        ) { [weak self] in
            self?.loadCharacters()
        }
        
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }
    
    private func showEmptyState() {
        emptyStateView.configure(
            image: UIImage(systemName: "magnifyingglass"),
            title: "No Characters Found",
            message: "Try searching for something else",
            buttonTitle: nil,
            action: nil
        )
        
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }
}

extension CharactersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCharacters
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CharacterCell.reuseIdentifier, for: indexPath) as? CharacterCell else {
            return UITableViewCell()
        }
        
        let character = viewModel.character(at: indexPath.row)
        let isFavorite = viewModel.isFavorite(character.id)
        
        cell.configure(with: character, isFavorite: isFavorite)
        
        cell.favoriteButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            _ = self.viewModel.toggleFavorite(character: character)
            cell.updateFavoriteButton(isFavorite: self.viewModel.isFavorite(character.id))
        }
        
        // Load more when reaching the end
        if indexPath.row == viewModel.numberOfCharacters - 5 && !viewModel.isLoading {
            viewModel.loadCharacters(loadMore: true)
        }
        
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
}

extension CharactersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            viewModel.searchQuery = ""
            return
        }
        
        // Add a short delay to avoid making an API call for each character typed
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch(_:)), object: nil)
        perform(#selector(performSearch(_:)), with: query, afterDelay: 0.5)
    }
    
    @objc private func performSearch(_ query: String) {
        viewModel.searchQuery = query
    }
}

extension CharactersViewController: CharacterListViewModelDelegate {
    func didUpdateCharacters() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
            
            if self.viewModel.numberOfCharacters == 0 {
                self.showEmptyState()
            } else {
                self.emptyStateView.isHidden = true
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
    
    func didEncounterError(_ error: NetworkError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.activityIndicator.stopAnimating()
            self.tableView.refreshControl?.endRefreshing()
            
            self.showErrorState(with: error.message)
        }
    }
}
