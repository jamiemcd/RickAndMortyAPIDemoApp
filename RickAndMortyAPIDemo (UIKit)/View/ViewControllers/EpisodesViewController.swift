//
//  EpisodesViewController.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/11/22.
//

import UIKit

class EpisodesViewController: UIViewController {
    
    // MARK: Internal Properties
        
    enum Action {
        case selectEpisode(Episode)
    }
    
    var actionHandler: ((_ action:Action) -> Void)?
    
    // MARK: UIViewController Properties
    
    // MARK: IBOutlets
    
    // MARK: Private Properties
    
    private var viewModel: ViewModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewModel
    }
    
    private var viewModelChangeHandlerToken: UUID?
    
    private var collectionView: UICollectionView!
    
    private enum Section {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Episode.ID>!
    
    // MARK: Init / Deinit
    
    static func make() -> EpisodesViewController {
        return EpisodesViewController()
    }
    
    deinit {
        if let viewModelChangeHandlerToken = viewModelChangeHandlerToken {
            viewModel.removeChangeHandler(with: viewModelChangeHandlerToken)
        }
    }
    
    // MARK: Public Methods
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {        
        super.viewDidLoad()
        title = "Episodes"
        view.backgroundColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.searchResultsUpdater = self
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(collectionView.topAnchor.constraint(equalTo: view.topAnchor))
        constraints.append(collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
        
        configureDataSource()

        viewModelChangeHandlerToken = viewModel.addChangeHandler { [weak self] in
            self?.updateUI()
        }
        
        updateUI()
    }
        
    // MARK: IBActions
    
    // MARK: Private Methods
    
    private func configureDataSource() {
        let episodeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Episode.ID> { [weak self] cell, indexPath, episodeID in
            guard let self = self, let episode = self.viewModel.episodes(for: [episodeID]).first else { return }
            let contentConfiguration = EpisodeCellContentConfiguration(episode: episode)
            cell.contentConfiguration = contentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Episode.ID>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, episodeID: Episode.ID) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: episodeID)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func updateUI() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Episode.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.filteredEpisodes.map { $0.id })
        dataSource.apply(snapshot)
    }

}

// MARK: - UICollectionViewDelegate

extension EpisodesViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let episodeID = dataSource.itemIdentifier(for: indexPath), let episode = viewModel.episodes(for: [episodeID]).first, let actionHandler = actionHandler {
            actionHandler(.selectEpisode(episode))
        }
    }
}

// MARK: - UISearchResultsUpdating

extension EpisodesViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}
