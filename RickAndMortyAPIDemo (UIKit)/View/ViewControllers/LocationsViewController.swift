//
//  LocationsViewController.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/11/22.
//

import UIKit

class LocationsViewController: UIViewController {
    
    // MARK: Internal Properties
    
    enum Action {
        case selectLocation(Location)
    }
    
    var actionHandler: ((_ action: Action) -> Void)?
    
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
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Location.ID>!
    
    // MARK: Init / Deinit
    
    
    static func make() -> LocationsViewController {
        return LocationsViewController()
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
        title = "Locations"
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
        let listCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Location.ID> { [weak self] cell, indexPath, locationID in
            guard let self = self, let location = self.viewModel.locations(for: [locationID]).first else { return }
            var contentConfiguration = cell.defaultContentConfiguration()
            contentConfiguration.text = location.name
            contentConfiguration.textProperties.color = .link
            cell.contentConfiguration = contentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Location.ID>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, locationID: Location.ID) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: locationID)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func updateUI() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Location.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.filteredLocations.map { $0.id })
        dataSource.apply(snapshot)
    }

}

// MARK: - UICollectionViewDelegate

extension LocationsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let locationID = dataSource.itemIdentifier(for: indexPath), let location = viewModel.locations(for: [locationID]).first, let actionHandler = actionHandler {
            actionHandler(.selectLocation(location))
        }
    }
}

// MARK: - UISearchResultsUpdating

extension LocationsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}

