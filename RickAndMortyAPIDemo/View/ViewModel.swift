//
//  ViewModel.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import Foundation
import UIKit.UIImage
import SwiftUI

@MainActor
class ViewModel: ObservableObject {
    
    // MARK: Internal Properties
    
    var searchText = "" {
        didSet {
            updateFilteredCharacters()
            updateFilteredLocations()
            updateFilteredEpisodes()
        }
    }
        
    @Published
    var filteredCharacters: [Character] = []
    
    @Published
    var filteredLocations: [Location] = []
    
    @Published
    var filteredEpisodes: [Episode] = []
    
    @Published
    var tabViewSelection: TabViewSelection = .characters
    
    enum TabViewSelection {
        case characters
        case locations
        case episodes
    }
        
    @Published
    var rootModelItem: ModelItem?
    
    enum ModelItem: Identifiable {
        var id: String {
            switch self {
            case .character(let character):
                return "character\(character.id)"
            case .location(let location):
                return "location\(location.id)"
            case .episode(let episode):
                return "episode\(episode.id)"
            }
        }
        
        case character(Character)
        case location(Location)
        case episode(Episode)
    }
        
    @Published
    var navigationPath = NavigationPath()
                
    // MARK: Private Properties
    
    private var characters: [Character] = []
    private var locations: [Location] = []
    private var episodes: [Episode] = []
    
    private lazy var cache: NSCache<NSString, UIImage> = {
        var cache = NSCache<NSString, UIImage>()
        return cache
    }()
    
    // MARK: Init / Deinit
    
    // MARK: Public Methods
    
    func episodes(for ids:[Episode.ID]) -> [Episode] {
        var episodeIds: [Episode.ID: Episode] = [:]
        for episode in episodes {
            episodeIds[episode.id] = episode
        }
        var array: [Episode] = []
        for id in ids {
            if let episode = episodeIds[id] {
                array.append(episode)
            }
        }
        return array
    }
    
    func characters(for ids:[Character.ID]) -> [Character] {
        var characterIds: [Character.ID: Character] = [:]
        for character in characters {
            characterIds[character.id] = character
        }
        var array: [Character] = []
        for id in ids {
            if let character = characterIds[id] {
                array.append(character)
            }
        }
        return array
    }
    
    func locations(for ids:[Location.ID]) -> [Location] {
        var locationIds: [Location.ID: Location] = [:]
        for location in locations {
            locationIds[location.id] = location
        }
        var array: [Location] = []
        for id in ids {
            if let location = locationIds[id] {
                array.append(location)
            }
        }
        return array
    }
    
    func selectTabView(_ tabViewSelection: TabViewSelection) {
        self.tabViewSelection = tabViewSelection
    }
    
    func selectCharacter(withID id: Character.ID) {
        if let character = characters.first(where: { $0.id == id }) {
            if rootModelItem == nil {
                rootModelItem = .character(character)
            }
            else {
                navigationPath.append(character)
            }
        }
    }
    
    func selectLocation(withID id: Location.ID) {
        if let location = locations.first(where: { $0.id == id }) {
            if rootModelItem == nil {
                rootModelItem = .location(location)
            }
            else {
                navigationPath.append(location)
            }
        }
        
    }
    
    func selectEpisode(withId id: Episode.ID) {
        if let episode = episodes.first(where: { $0.id == id }) {
            if rootModelItem == nil {
                rootModelItem = .episode(episode)
            }
            else {
                navigationPath.append(episode)
            }
        }
    }
        
    func removeRootModelItem() {
        rootModelItem = nil
        navigationPath = NavigationPath()
    }
    
    
    func uiImage(for character: Character) -> UIImage? {
        let key = NSString(string: "\(character.id)")
        if let uiImage = cache.object(forKey: key)
        {
            return uiImage
        }
        else if let data = try? Data(contentsOf: character.localImageURL), let uiImage = UIImage(data: data) {
            cache.setObject(uiImage, forKey: key)
            return uiImage
        }
        return nil
    }
    
    func downloadImage(for character: Character) {
        guard let imageURL = character.imageURL else { return }
        Task {
            do {
                let data = try await Cloud.sharedCloud.getData(imageURL)
                try data.write(to: character.localImageURL)
                if let index = self.characters.firstIndex(where: { $0.id == character.id }) {
                    self.characters[index] = Character(id: character.id, name: character.name, status: character.status, species: character.species, type: character.type, gender: character.gender, origin: character.origin, lastKnownLocation: character.lastKnownLocation, imageURL: character.imageURL, episodes: character.episodes, imageDownloadDate: Date())
                }
                updateFilteredCharacters()
            }
            catch {
                
            }
        }
    }
    
    func getCharacters() async {
        characters = []
        filteredCharacters = []
        for await characterResponse in Cloud.sharedCloud.getCharactersStream() {
            let array = Character.characters(from: [characterResponse])
            characters.append(contentsOf: array)
            updateFilteredCharacters()
        }
    }
    
    func getLocations() async {
        locations = []
        filteredLocations = []
        for await locationResponse in Cloud.sharedCloud.getLocationsStream() {
            let array = Location.locations(from: [locationResponse])
            locations.append(contentsOf: array)
            updateFilteredLocations()
        }
    }
    
    func getEpisodes() async {
        episodes = []
        filteredEpisodes = []
        for await episodeResponse in Cloud.sharedCloud.getEpisodesStream() {
            let array = Episode.episodes(from: [episodeResponse])
            episodes.append(contentsOf: array)
            updateFilteredEpisodes()
        }
    }
    
    func getAllCharacters() async {
        if let characterResponses = try? await Cloud.sharedCloud.getCharacters() {
            characters = Character.characters(from: characterResponses)
            updateFilteredCharacters()
        }
    }
    
    func getAllLocations() async {
        if let locationResponses = try? await Cloud.sharedCloud.getLocations() {
            locations = Location.locations(from: locationResponses)
            updateFilteredLocations()
        }
    }
    
    func getAllEpisodes() async {
        if let episodeResponses = try? await Cloud.sharedCloud.getEpisodes() {
            episodes = Episode.episodes(from: episodeResponses)
            updateFilteredEpisodes()
        }
    }
    
    // MARK: Private Methods
    
    private func updateFilteredCharacters() {
        if searchText.isEmpty {
            filteredCharacters = characters
        }
        else {
            filteredCharacters = characters.filter { $0.name.contains(searchText) }
        }
    }
    
    private func updateFilteredLocations() {
        if searchText.isEmpty {
            filteredLocations = locations
        }
        else {
            filteredLocations = locations.filter { $0.name.contains(searchText) }
        }
    }
    
    private func updateFilteredEpisodes() {
        if searchText.isEmpty {
            filteredEpisodes = episodes
        }
        else {
            filteredEpisodes = episodes.filter { $0.name.contains(searchText) }
        }
    }
}
