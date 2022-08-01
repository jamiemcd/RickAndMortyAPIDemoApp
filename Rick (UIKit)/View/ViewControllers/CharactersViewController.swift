//
//  CharactersViewController.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/11/22.
//

import UIKit

class CharactersViewController: UIViewController {

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
    
    private var viewModelChangeHandlerToken: UUID?
    
    private var collectionView: UICollectionView!
    
    private enum Section: Int, CaseIterable {
        case main
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Character.ID>!
    
    private var characters: [Character.ID: Character] = [:]
    
    // MARK: Init / Deinit
    
    static func make() -> CharactersViewController {
        return CharactersViewController()
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
        title = "Characters"
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
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Character.ID> { [weak self] cell, indexPath, characterID in
            guard let self = self, let character = self.viewModel.characters(for: [characterID]).first else { return }
            let contentConfiguration = CharacterCellContentConfiguration(character: character, viewModel: self.viewModel, style: .standardWithEpisodeCount)
            cell.contentConfiguration = contentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Character.ID>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, characterID: Character.ID) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: characterID)
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
            case .main:
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
        if navigationItem.searchController?.searchBar.text != viewModel.searchText {
            navigationItem.searchController?.searchBar.text = viewModel.searchText
        }

        // First, determine if any Characters have changed their imageDownloadDate
        var characterIDsToUpdate: [Character.ID] = []
        let characters = viewModel.filteredCharacters
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
        var snapshot = NSDiffableDataSourceSnapshot<Section, Character.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(characters.map { $0.id })
        if !characterIDsToUpdate.isEmpty {
            // snapshot.reloadItems(characterIDsToUpdate)
            // These cell will be reconfigured instead of reloaded
            snapshot.reconfigureItems(characterIDsToUpdate)
        }
        
        dataSource.apply(snapshot)
    }
    
}

// MARK: - UICollectionViewDelegate

extension CharactersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if let characterID = dataSource.itemIdentifier(for: indexPath), let character = viewModel.characters(for: [characterID]).first, let actionHandler = actionHandler {
            actionHandler(.selectCharacter(character))
        }
    }
}

// MARK: - UISearchResultsUpdating

extension CharactersViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
    }
}
