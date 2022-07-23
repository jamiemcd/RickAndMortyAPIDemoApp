//
//  CharacterDetailViewController.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/13/22.
//

import UIKit

class CharacterDetailViewController: UIViewController {

    // MARK: Internal Properties
    
    enum Action {
        case selectEpisode(Episode)
        case selectLocation(Location)
    }
    
    var actionHandler: ((_ action: Action) -> Void)?
    
    // MARK: UIViewController Properties
        
    // MARK: Private Properties
        
    private var viewModel: ViewModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewModel
    }
    
    private var character: Character!
    private var collectionView: UICollectionView!
    private var viewModelChangeHandlerToken: UUID?
    
    private enum Section {
        case imageAndName
        case species
        case gender
        case type
        case status
        case origin
        case lastKnownLocation
        case episodes
    }
    
    private enum Item: Hashable {
        case imageAndName
        case species
        case gender
        case type
        case status
        case origin
        case lastKnownLocation
        case episode(Episode.ID)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    // MARK: Init / Deinit
    
    static func make(_ character: Character) -> CharacterDetailViewController {
        let characterDetailViewController = CharacterDetailViewController()
        characterDetailViewController.character = character
        return characterDetailViewController
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
        view.backgroundColor = .white
        
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
        
    // MARK: Private Methods
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { [weak self] cell, indexPath, item in
            guard let self = self, case .imageAndName = item else { return }
            let contentConfiguration = CharacterCellContentConfiguration(character: self.character, viewModel: self.viewModel, style: .large)
            cell.contentConfiguration = contentConfiguration
        }
        
        let listCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            var contentConfiguration = cell.defaultContentConfiguration()
            switch item {
            case .imageAndName:
                break
            case .species:
                contentConfiguration.text = self.character.species
            case .gender:
                contentConfiguration.text = self.character.gender.rawValue
            case .type:
                contentConfiguration.text = self.character.type ?? "Unknown"
            case .status:
                contentConfiguration.text = self.character.status.rawValue
            case .origin:
                if let origin = self.character.origin, let location = self.viewModel.locations(for: [origin.id]).first {
                    contentConfiguration.text = location.name
                    contentConfiguration.textProperties.color = .link
                    cell.accessories = [.disclosureIndicator()]
                }
                else {
                    contentConfiguration.text = "Unknown"
                }
            case .lastKnownLocation:
                if let lastKnownLocation = self.character.lastKnownLocation, let location = self.viewModel.locations(for: [lastKnownLocation.id]).first {
                    contentConfiguration.text = location.name
                    contentConfiguration.textProperties.color = .link
                    cell.accessories = [.disclosureIndicator()]
                }
                else {
                    contentConfiguration.text = "Unknown"
                }
            case .episode:
                break
            }
            cell.contentConfiguration = contentConfiguration
        }
        
        let episodeCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, indexPath, item in
            guard let self = self, case let .episode(episodeID) = item, let episode = self.viewModel.episodes(for: [episodeID]).first else { return }
            let contentConfiguration = EpisodeCellContentConfiguration(episode: episode)
            cell.accessories = [.disclosureIndicator()]
            cell.contentConfiguration = contentConfiguration
        }
                
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self = self else { return }
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            var configuration = supplementaryView.defaultContentConfiguration()
            switch section {
            case .imageAndName:
                break
            case .species:
                configuration.text = "Species"
            case .gender:
                configuration.text = "Gender"
            case .type:
                configuration.text = "Type"
            case .status:
                configuration.text = "Status"
            case .origin:
                configuration.text = "Origin"
            case .lastKnownLocation:
                configuration.text = "Last Known Location"
            case .episodes:
                configuration.text = "\(self.character.episodes.count) Episodes"
            }
            supplementaryView.contentConfiguration = configuration
        }
            
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            switch item {
            case .imageAndName:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            case .species, .gender, .type, .status, .origin, .lastKnownLocation:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: item)
            case .episode:
                return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: item)
            }
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func updateUI() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.imageAndName])
        snapshot.appendItems([.imageAndName])
        snapshot.appendSections([.species])
        snapshot.appendItems([.species])
        snapshot.appendSections([.gender])
        snapshot.appendItems([.gender])
        if character.type != nil {
            snapshot.appendSections([.type])
            snapshot.appendItems([.type])
        }
        snapshot.appendSections([.status])
        snapshot.appendItems([.status])
        snapshot.appendSections([.origin])
        snapshot.appendItems([.origin])
        snapshot.appendSections([.lastKnownLocation])
        snapshot.appendItems([.lastKnownLocation])
        let episodes = viewModel.episodes(for: character.episodes).map { Item.episode($0.id) }
        snapshot.appendSections([.episodes])
        snapshot.appendItems(episodes)
        dataSource.apply(snapshot)
    }

}

// MARK: - UICollectionViewDelegate

extension CharacterDetailViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        if let item = dataSource.itemIdentifier(for: indexPath) {
            switch item {
            case .imageAndName:
                return false
            case .species:
                return false
            case .gender:
                return false
            case .type:
                return false
            case .status:
                return false
            case .origin:
                return character.origin != nil
            case .lastKnownLocation:
                return character.lastKnownLocation != nil
            case .episode:
                return true
            }
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let item = dataSource.itemIdentifier(for: indexPath), let actionHandler = actionHandler {
            switch item {
            case .imageAndName:
                break
            case .species:
                break
            case .gender:
                break
            case .type:
                break
            case .status:
                break
            case .origin:
                if let originID = character.origin?.id, let location = viewModel.locations(for: [originID]).first {
                    actionHandler(.selectLocation(location))
                }
            case .lastKnownLocation:
                if let lastKnownLocationID = character.lastKnownLocation?.id, let location = viewModel.locations(for: [lastKnownLocationID]).first {
                    actionHandler(.selectLocation(location))
                }
            case .episode(let episodeID):
                if let episode = viewModel.episodes(for: [episodeID]).first {
                    actionHandler(.selectEpisode(episode))
                }
            }
        }
    }
}
