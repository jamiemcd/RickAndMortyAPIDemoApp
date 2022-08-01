//
//  ViewModel.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/12/22.
//

import UIKit

@MainActor
class ViewModel {
    
    // MARK: Internal Properties
    
    var searchText = "" {
        didSet {
            updateFilteredCharacters()
            updateFilteredLocations()
            updateFilteredEpisodes()
        }
    }
    
    var filteredCharacters: [Character] = []
    var filteredLocations: [Location] = []
    var filteredEpisodes: [Episode] = []
    
    
    // MARK: Private Properties
    
    private var characters: [Character.ID: Character] = [:]
    private var locations: [Location.ID: Location] = [:]
    private var episodes: [Episode.ID: Episode] = [:]
    
    private lazy var cache: NSCache<NSString, UIImage> = {
        var cache = NSCache<NSString, UIImage>()
        return cache
    }()
    
    private var changeHandlers: [UUID: () -> Void] = [:]
    
    // MARK: Init / Deinit
    
    // MARK: Public Methods
    
    func addChangeHandler(changeHandler: @escaping () -> Void) -> UUID {
        let uuid = UUID()
        changeHandlers[uuid] = changeHandler
        return uuid
    }
    
    func removeChangeHandler(with uuid: UUID) {
        changeHandlers[uuid] = nil
    }
    
    func callChangeHandlers() {
        for changeHandler in self.changeHandlers.values {
            changeHandler()
        }
    }
    
    func episodes(for ids:[Episode.ID]) -> [Episode] {
        var array: [Episode] = []
        for id in ids {
            if let episode = episodes[id] {
                array.append(episode)
            }
        }
        return array
    }
    
    func characters(for ids:[Character.ID]) -> [Character] {
        var array: [Character] = []
        for id in ids {
            if let character = characters[id] {
                array.append(character)
            }
        }
        return array
    }
    
    func locations(for ids:[Location.ID]) -> [Location] {
        var array: [Location] = []
        for id in ids {
            if let location = locations[id] {
                array.append(location)
            }
        }
        return array
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
                self.characters[character.id] = Character(id: character.id, name: character.name, status: character.status, species: character.species, type: character.type, gender: character.gender, origin: character.origin, lastKnownLocation: character.lastKnownLocation, imageURL: character.imageURL, episodes: character.episodes, imageDownloadDate: Date())
                updateFilteredCharacters()
            }
            catch {
                
            }
        }
    }
    
    func getCharacters() async {
        characters = [:]
        filteredCharacters = []
        for await characterResponse in Cloud.sharedCloud.getCharactersStream() {
            let array = Character.characters(from: [characterResponse])
            for character in array {
                characters[character.id] = character
            }
            updateFilteredCharacters()
        }
    }
    
    func getLocations() async {
        locations = [:]
        filteredLocations = []
        for await locationResponse in Cloud.sharedCloud.getLocationsStream() {
            let array = Location.locations(from: [locationResponse])
            for location in array {
                locations[location.id] = location
            }
            updateFilteredLocations()
        }
    }
    
    func getEpisodes() async {
        episodes = [:]
        filteredEpisodes = []
        for await episodeResponse in Cloud.sharedCloud.getEpisodesStream() {
            let array = Episode.episodes(from: [episodeResponse])
            for episode in array {
                episodes[episode.id] = episode
            }
            updateFilteredEpisodes()
        }
    }

    
    // MARK: Private Methods
    
    private func updateFilteredCharacters() {
        var array = characters.values.map { $0 }
        if !searchText.isEmpty {
            array = array.filter { $0.name.contains(searchText) }
        }
        filteredCharacters = array.sorted { $0.id < $1.id }
        callChangeHandlers()
    }
    
    private func updateFilteredLocations() {
        var array = locations.values.map { $0 }
        if !searchText.isEmpty {
            array = array.filter { $0.name.contains(searchText) }
        }
        filteredLocations = array.sorted { $0.id < $1.id }
        callChangeHandlers()
    }
    
    private func updateFilteredEpisodes() {
        var array = episodes.values.map { $0 }
        if !searchText.isEmpty {
            array = array.filter { $0.name.contains(searchText) }
        }
        filteredEpisodes = array.sorted { $0.id < $1.id }
        callChangeHandlers()
    }
    
}
