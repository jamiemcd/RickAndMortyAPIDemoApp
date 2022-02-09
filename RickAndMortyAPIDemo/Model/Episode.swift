//
//  Episode.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import Foundation

struct Episode: Identifiable, Hashable {
    let id: Int
    let name: String
    let formattedAirDate: String
    let code: String
    let characters: [Int] // an array of Character.id
        
    static func episodes(from episodeResponses: [Cloud.EpisodeResponse]) -> [Episode] {
        var episodes: [Episode] = []
        for episodeResponse in episodeResponses {
            for result in episodeResponse.results {
                var characters: [Int] = []
                for urlString in result.characters {
                    if let idString = urlString.split(separator: "/").last, let id = Int(idString) {
                        characters.append(id)
                    }
                }
                let episode = Episode(id: result.id,
                                      name: result.name,
                                      formattedAirDate: result.airDate,
                                      code: result.episode,
                                      characters: characters)
                episodes.append(episode)
            }
        }
        
        return episodes
    }
    
}
