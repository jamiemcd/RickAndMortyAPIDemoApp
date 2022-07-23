//
//  DetailNavigationController.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/13/22.
//

import UIKit

class DetailNavigationController: UINavigationController {

    // MARK: Internal Properties
    
    enum Action {
        case done
    }
    
    var actionHandler: ((_ action: Action) -> Void)?
    
    enum DetailNavigationControllerType {
        case character(Character)
        case location(Location)
        case episode(Episode)
        case unknown
    }
    
    
    // MARK: UIViewController Properties
    
    // MARK: IBOutlets
    
    // MARK: Private Properties
    
    private(set) var detailNavigationControllerType: DetailNavigationControllerType = .unknown
            
    private var doneBarButtonItem: UIBarButtonItem!
    
    // MARK: Init / Deinit
    
    static func make(_ detailNavigationControllerType: DetailNavigationControllerType) -> DetailNavigationController {
        let detailNavigationController = DetailNavigationController()
        detailNavigationController.detailNavigationControllerType = detailNavigationControllerType
        return detailNavigationController
    }
        
    // MARK: Public Methods
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        presentationController?.delegate = self
        
        switch detailNavigationControllerType {
        case .character(let character):
            pushCharacterDetailViewController(character)
        case .location(let location):
            pushLocationDetailViewController(location)
        case .episode(let episode):
            pushEpisodeDetailViewController(episode)
        case .unknown:
            break
        }
        
        doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemTouchHandler))
        navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    // MARK: IBActions
    
    // MARK: Private Methods
    
    private func characterDetailViewController(_ character: Character)  -> CharacterDetailViewController{
        let characterDetailViewController = CharacterDetailViewController.make(character)
        characterDetailViewController.actionHandler = { [weak self] action in
            switch action {
            case .selectEpisode(let episode):
                self?.pushEpisodeDetailViewController(episode)
            case .selectLocation(let location):
                self?.pushLocationDetailViewController(location)
            }
        }
        return characterDetailViewController
    }
    
    private func locationDetailViewController(_ location: Location) -> LocationDetailViewController {
        let locationDetailViewController = LocationDetailViewController.make(location)
        locationDetailViewController.actionHandler = { [weak self] action in
            switch action {
            case .selectCharacter(let character):
                self?.pushCharacterDetailViewController(character)
            }
        }
        return locationDetailViewController
    }
    
    private func episodeDetailViewController(_ episode: Episode) -> EpisodeDetailViewController {
        let episodeDetailViewController = EpisodeDetailViewController.make(episode)
        episodeDetailViewController.actionHandler = { [weak self] action in
            switch action {
            case .selectCharacter(let character):
                self?.pushCharacterDetailViewController(character)
            }
        }
        return episodeDetailViewController
    }
    
    private func pushCharacterDetailViewController(_ character: Character) {
        pushViewController(characterDetailViewController(character), animated: true)
    }
    
    private func pushLocationDetailViewController(_ location: Location) {
        pushViewController(locationDetailViewController(location), animated: true)
    }
    
    private func pushEpisodeDetailViewController(_ episode: Episode) {
        pushViewController(episodeDetailViewController(episode), animated: true)
    }
    
    @objc private func doneBarButtonItemTouchHandler() {
        if let actionHandler = actionHandler {
            actionHandler(.done)
        }
    }

}

// MARK: - UINavigationControllerDelegate

extension DetailNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension DetailNavigationController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let actionHandler = actionHandler {
            actionHandler(.done)
        }
    }
    
}
