//
//  Cloud.LocationResponse.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/3/22.
//

import Foundation

extension Cloud {
    
    struct LocationResponse: InfoResponse {
        let info: Info
        let results: [Result]
                
        struct Result: Codable {
            let id: Int
            let name: String
            let type: String
            let dimension: String
            let residents: [String]
            let url: String
            let created: String
        }
    }
}
