//
//  Character.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import Foundation

struct Character: Identifiable, Hashable {
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum Status: String {
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "unknown"
    }
    
    enum Gender: String {
        case female = "Female"
        case male = "Male"
        case genderless = "Genderless"
        case unknown = "unknown"
    }
    
    let id: Int
    let name: String
    let status: Status
    let species: String
    let type: String?
    let gender: Gender
    let origin: Origin?
    
    struct Origin {
        let name: String
        let id: Int
    }
    
    let lastKnownLocation: LastKnownLocation?
    
    struct LastKnownLocation {
        let name: String
        let id: Int
    }
    
    let imageURL: URL?
    let episodes: [Int] // an array of Episode.id
    
    var imageDownloadDate: Date?
    
    var localImageURL: URL {
        let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("character-\(id)")
    }
    
    var hasLocalImage: Bool {
        return FileManager.default.fileExists(atPath: localImageURL.path)
    }
            
    static func characters(from characterResponses: [Cloud.CharacterResponse]) -> [Character] {
        var characters: [Character] = []
        
        for characterResponse in characterResponses {
            for result in characterResponse.results {
                var origin: Origin?
                if let idString = result.origin.url.split(separator: "/").last, let id = Int(idString) {
                    origin = Origin(name: result.origin.name, id: id)
                }
                
                var lastKnownLocation: LastKnownLocation?
                if let idString = result.location.url.split(separator: "/").last, let id = Int(idString) {
                    lastKnownLocation = LastKnownLocation(name: result.location.name, id: id)
                }
                
                var episodes: [Int] = []
                for urlString in result.episode {
                    if let idString = urlString.split(separator: "/").last, let id = Int(idString) {
                        episodes.append(id)
                    }
                }
                
                let character = Character(id: result.id,
                                          name: result.name,
                                          status: Status(rawValue: result.status) ?? .unknown,
                                          species: result.species,
                                          type: !result.type.isEmpty ? result.type : nil,
                                          gender: Gender(rawValue: result.gender) ?? .unknown,
                                          origin: origin,
                                          lastKnownLocation: lastKnownLocation,
                                          imageURL: URL(string: result.image),
                                          episodes: episodes)
                characters.append(character)
            }
        }
        
        return characters
    }
}


