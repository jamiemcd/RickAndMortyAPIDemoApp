//
//  ViewModel.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import Foundation
import UIKit.UIImage

@MainActor
class ViewModel: ObservableObject {
    
    // MARK: Internal Properties
    
    var charactersListSearchText = "" {
        didSet {
            updateFilteredCharacters()
        }
    }
    
    @Published
    var filteredCharacters: [Character] = []
    
    @Published
    var locations: [Location] = []
    
    @Published
    var episodes: [Episode] = []
    
    @Published
    var tabViewSelection: TabViewSelection = .characters
    
    enum TabViewSelection {
        case characters
        case locations
        case episodes
    }
    
    @Published
    var characterListSelection: Character?
    
    @Published
    var locationListSelection: Location?
    
    @Published
    var episodeListSelection: Episode?
    
    // MARK: Private Properties
    
    private var characters: [Character] = []
    
    private lazy var cache: NSCache<NSString, UIImage> = {
        var cache = NSCache<NSString, UIImage>()
        return cache
    }()
    
    // MARK: Init / Deinit
    
    // MARK: Public Methods
    
    func episodes(for ids:[Int]) -> [Episode] {
        var episodeIds: [Int: Episode] = [:]
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
    
    func characters(for ids:[Int]) -> [Character] {
        var characterIds: [Int: Character] = [:]
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
    
    func selectTabView(_ tabViewSelection: TabViewSelection) {
        self.tabViewSelection = tabViewSelection
    }
    
    func selectCharacter(withID id: Int) {
        self.characterListSelection = characters.first { $0.id == id }
    }
    
    func selectEpisode(withId id: Int) {
        self.episodeListSelection = episodes.first{ $0.id == id }
    }
    
    func deselectCharacter() {
        self.characterListSelection = nil
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
        for await locationResponse in Cloud.sharedCloud.getLocationsStream() {
            locations.append(contentsOf: Location.locations(from: [locationResponse]))
        }
    }
    
    func getEpisodes() async {
        episodes = []
        for await episodeResponse in Cloud.sharedCloud.getEpisodesStream() {
            episodes.append(contentsOf: Episode.episodes(from: [episodeResponse]))
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
        }
    }
    
    func getAllEpisodes() async {
        if let episodeResponses = try? await Cloud.sharedCloud.getEpisodes() {
            episodes = Episode.episodes(from: episodeResponses)
        }
    }
    
    // MARK: Private Methods
    
    private func updateFilteredCharacters() {
        if charactersListSearchText.isEmpty {
            filteredCharacters = characters
        }
        else {
            filteredCharacters = characters.filter { $0.name.contains(charactersListSearchText) }
        }
    }
}
