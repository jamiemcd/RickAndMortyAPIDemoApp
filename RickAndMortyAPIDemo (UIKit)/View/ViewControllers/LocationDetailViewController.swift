//
//  LocationDetailViewController.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/13/22.
//

import UIKit

class LocationDetailViewController: UIViewController {

    // MARK: Internal Properties
    
    enum Action {
        case selectCharacter(Character)
    }
    
    var actionHandler: ((_ action: Action) -> Void)?
    
    // MARK: UIViewController Properties
    
    // MARK: IBOutlets
    
    // MARK: Private Properties
    
    private struct Constants {
        static let idealCellWidth: CGFloat = 150
        static let cellSpacing: CGFloat = 6
    }
    
    private var viewModel: ViewModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewModel
    }
    
    private var location: Location!
    private var collectionView: UICollectionView!
    private var viewModelChangeHandlerToken: UUID?
    
    // Section is Int because when you use the UICollectionViewCompositionalLayout(sectionProvider:) method, the sectionProvider
    // is a closure whose sectionIndex parameter is of type Int
    private enum Section: Int {
        case detail
        case characters
    }
    
    private enum Item: Hashable {
        case detail
        case character(Character.ID)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
        
    private var characters: [Character.ID: Character] = [:]
    
    // MARK: Init / Deinit
    
    static func make(_ location: Location) -> LocationDetailViewController {
        let locationDetailViewController = LocationDetailViewController()
        locationDetailViewController.location = location
        return locationDetailViewController
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
    
    // MARK: IBActions
    
    // MARK: Private Methods

    private func configureDataSource() {
        
        let detailCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { [weak self] cell, indexPath, item in
            guard let self = self, case .detail = item else { return }
            let contentConfiguration = DetailCellContentConfiguration(name: self.location.name,
                                                                      firstText: "Type",
                                                                      firstValue: self.location.type,
                                                                      secondText: "Dimension",
                                                                      secondValue: self.location.dimension,
                                                                      thirdText: "Residents",
                                                                      thirdValue: "\(self.location.residents.count)")
            cell.contentConfiguration = contentConfiguration
        }
        
        
        let characterCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { [weak self] cell, indexPath, item in
            guard let self = self, case .character(let characterID) = item, let character = self.viewModel.characters(for: [characterID]).first else { return }
            let contentConfiguration = CharacterCellContentConfiguration(character: character, viewModel: self.viewModel, style: .standard)
            cell.contentConfiguration = contentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            switch item {
            case .detail:
                return collectionView.dequeueConfiguredReusableCell(using: detailCellRegistration, for: indexPath, item: item)
            case .character:
                return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: item)
            }
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            // calculate cell width
            let width = layoutEnvironment.container.effectiveContentSize.width - layoutEnvironment.container.effectiveContentInsets.leading - layoutEnvironment.container.effectiveContentInsets.trailing
            let columnCount = max(1, Int(width / Constants.idealCellWidth))
            let totalCellSpacing = CGFloat(columnCount - 1) * Constants.cellSpacing
            var cellWidth = floor((width - totalCellSpacing) / CGFloat(columnCount))
            cellWidth = max(0, cellWidth)
            
            switch section {
            case .detail:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let layoutSection = NSCollectionLayoutSection(group: group)
                return layoutSection
            case .characters:
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(cellWidth), heightDimension: .estimated(Constants.idealCellWidth))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(Constants.cellSpacing)
                let layoutSection = NSCollectionLayoutSection(group: group)
                layoutSection.interGroupSpacing = Constants.cellSpacing
                return layoutSection
            }
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func updateUI() {
        // First, determine if any Characters have changed their imageDownloadDate
        var characterIDsToUpdate: [Character.ID] = []
        let characters = viewModel.characters(for: location.residents)
        for character in characters {
            if let existingCharacter = self.characters[character.id], existingCharacter.imageDownloadDate != character.imageDownloadDate {
                characterIDsToUpdate.append(character.id)
            }
        }
        
        // Next, rebuild the characters dictionary
        self.characters = [:]
        for character in characters {
            self.characters[character.id] = character
        }
        
        // Finally, create the snapshot and apply it
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.detail])
        snapshot.appendItems([.detail])
        snapshot.appendSections([.characters])
        snapshot.appendItems(characters.map { .character($0.id) })
        if !characterIDsToUpdate.isEmpty {
            // snapshot.reloadItems(characterIDsToUpdate)
            // These cell will be reconfigured instead of reloaded
            snapshot.reconfigureItems(characterIDsToUpdate.map {.character($0) })
        }
        
        dataSource.apply(snapshot)
    }
    
}

// MARK: - UICollectionViewDelegate

extension LocationDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let item = dataSource.itemIdentifier(for: indexPath), let actionHandler = actionHandler {
            switch item {
            case .detail:
                break
            case .character(let characterID):
                if let character = viewModel.characters(for: [characterID]).first {
                    actionHandler(.selectCharacter(character))
                }
            }
        }
    }
    
}
