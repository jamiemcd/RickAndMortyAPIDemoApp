//
//  Cloud.EpisodeResponse.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/3/22.
//

import Foundation

extension Cloud {
    
    struct EpisodeResponse: InfoResponse {
        let info: Info
        let results: [Result]
        
        struct Result: Codable {
            let id: Int
            let name: String
            let airDate: String
            let episode: String
            let characters: [String]
            let url: String
            let created: String
        }
    }
}
