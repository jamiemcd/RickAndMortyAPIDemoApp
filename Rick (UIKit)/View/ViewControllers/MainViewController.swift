//
//  MainViewController.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/11/22.
//

import UIKit

class MainViewController: UITabBarController {
    
    // MARK: Internal Properties
    
    // MARK: UIViewController Properties
    
    // MARK: IBOutlets
    
    // MARK: Private Properties
    
    private var charactersViewController: CharactersViewController!
    private var locationsViewController: LocationsViewController!
    private var episodesViewController: EpisodesViewController!
    private var detailNavigationController: UINavigationController?
    
    private var viewModel: ViewModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.viewModel
    }
    
    // MARK: Init / Deinit
    
    // MARK: Public Methods
    
    // MARK: UIViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        charactersViewController = CharactersViewController.make()
        charactersViewController.actionHandler = { [weak self] action in
            switch action {
            case .selectCharacter(let character):
                self?.presentDetailNavigationController(.character(character))
            }
        }
        
        locationsViewController = LocationsViewController.make()
        locationsViewController.actionHandler = { [weak self] action in
            switch action {
            case .selectLocation(let location):
                self?.presentDetailNavigationController(.location(location))
            }
        }
        
        episodesViewController = EpisodesViewController.make()
        episodesViewController.actionHandler = { [weak self] action in
            switch action {
            case .selectEpisode(let episode):
                self?.presentDetailNavigationController(.episode(episode))
            }
        }
        
        let navigationController1 = UINavigationController(rootViewController: charactersViewController)
        navigationController1.tabBarItem = UITabBarItem(title: "Characters", image: UIImage(systemName: "person.3"), selectedImage: nil)
        
        let navigationController2 = UINavigationController(rootViewController: locationsViewController)
        navigationController2.tabBarItem = UITabBarItem(title: "Locations", image: UIImage(systemName: "globe.americas"), selectedImage: nil)
        
        let navigationController3 = UINavigationController(rootViewController: episodesViewController)
        navigationController3.tabBarItem = UITabBarItem(title: "Episodes", image: UIImage(systemName: "tv"), selectedImage: nil)
        
        viewControllers = [navigationController1, navigationController2, navigationController3]
                
        Task {
            await viewModel.getCharacters()
            await viewModel.getLocations()
            await viewModel.getEpisodes()
        }
    }
    
    // MARK: IBActions
    
    // MARK: Private Methods
    
    private func presentDetailNavigationController(_ detailNavigationControllerType: DetailNavigationController.DetailNavigationControllerType) {
        let detailNavigationController = DetailNavigationController.make(detailNavigationControllerType)
        detailNavigationController.actionHandler = { [weak self] action in
            switch action {
            case .done:
                self?.dismiss(animated: true) {
                    self?.detailNavigationController = nil
                }
            }
        }
        self.detailNavigationController = detailNavigationController
        present(detailNavigationController, animated: true)
    }

}



