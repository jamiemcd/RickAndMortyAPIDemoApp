//
//  ViewModel.swift
//  RickAndMortyAPIDemo (UIKit)
//
//  Created by Jamie McDaniel on 7/12/22.
//

import UIKit

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
    
    private var characters: [Character] = []
    private var locations: [Location] = []
    private var episodes: [Episode] = []
    
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
        DispatchQueue.main.async {
            for changeHandler in self.changeHandlers.values {
                changeHandler()
            }
        }
    }
    
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
            callChangeHandlers()
        }
    }
    
    func getLocations() async {
        locations = []
        filteredLocations = []
        for await locationResponse in Cloud.sharedCloud.getLocationsStream() {
            let array = Location.locations(from: [locationResponse])
            locations.append(contentsOf: array)
            updateFilteredLocations()
            callChangeHandlers()
        }
    }
    
    func getEpisodes() async {
        episodes = []
        filteredEpisodes = []
        for await episodeResponse in Cloud.sharedCloud.getEpisodesStream() {
            let array = Episode.episodes(from: [episodeResponse])
            episodes.append(contentsOf: array)
            updateFilteredEpisodes()
            callChangeHandlers()
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
        callChangeHandlers()
    }
    
    private func updateFilteredLocations() {
        if searchText.isEmpty {
            filteredLocations = locations
        }
        else {
            filteredLocations = locations.filter { $0.name.contains(searchText) }
        }
        callChangeHandlers()
    }
    
    private func updateFilteredEpisodes() {
        if searchText.isEmpty {
            filteredEpisodes = episodes
        }
        else {
            filteredEpisodes = episodes.filter { $0.name.contains(searchText) }
        }
        callChangeHandlers()
    }
    
}
