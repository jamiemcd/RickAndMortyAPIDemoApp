//
//  Cloud.CharacterResponse.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 12/16/21.
//

import Foundation

extension Cloud {
    
    struct CharacterResponse: InfoResponse {
        let info: Info
        let results: [Result]
        
        struct Result: Codable {
            let id: Int
            let name: String
            let status: String
            let species: String
            let type: String
            let gender: String
            let origin: Origin
            
            struct Origin: Codable {
                let name: String
                let url: String
            }
            
            let location: Location
            
            struct Location: Codable {
                let name: String
                let url: String
            }
            
            let image: String
            let episode: [String]
            let url: String
            let created: String
        }
    }
}
