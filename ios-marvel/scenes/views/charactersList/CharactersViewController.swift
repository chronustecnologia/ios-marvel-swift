//
//  CharactersViewController.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//

import UIKit

final class CharactersViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CharacterCell.self, forCellReuseIdentifier: CharacterCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl

        return tableView
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Pesquisar personagens"
        return searchController
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private lazy var emptyStateView: EmptyStateView = {
        let emptyStateView = EmptyStateView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        return emptyStateView
    }()
    
    private let viewModel = CharacterListViewModel()
    
    private let searchDebounceInterval: TimeInterval = 0.5
    
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
        title = "Personagens Marvel"
        view.backgroundColor = .systemBackground
        
        view.addSubview(activityIndicator)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupSearchController() {
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
            buttonTitle: "Tentar novamente"
        ) { [weak self] in
            self?.loadCharacters()
        }
        
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }
    
    private func showEmptyState() {
        emptyStateView.configure(
            image: UIImage(systemName: "magnifyingglass"),
            title: "Personagens não encontrados",
            message: "Tente procurar algo diferente",
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
        
        //if indexPath.row == viewModel.numberOfCharacters - 5 && !viewModel.isLoading {
        //    viewModel.loadCharacters(loadMore: true)
        //}
        
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

extension CharactersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        // Calculate when we're near bottom (e.g., within 200 points of the bottom)
        let distanceFromBottom = contentHeight - position - scrollViewHeight
        let threshold: CGFloat = 200.0
        
        // If we're close to the bottom and not already loading
        if distanceFromBottom < threshold && !viewModel.isLoading && contentHeight > 0 {
            viewModel.loadCharacters(loadMore: true)
        }
    }
}

extension CharactersViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text ?? ""
        viewModel.searchQuery = query
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchQuery = ""
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
