//
//  Location.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import Foundation

struct Location: Identifiable, Hashable {
    let id: Int
    let name: String
    let type: String
    let dimension: String
    let residents: [Int] // an array of Character.id
    
    static func locations(from locationResponses: [Cloud.LocationResponse]) -> [Location] {
        var locations: [Location] = []
        
        for locationResponse in locationResponses {
            for result in locationResponse.results {
                var residents: [Int] = []
                for urlString in result.residents {
                    if let idString = urlString.split(separator: "/").last, let id = Int(idString) {
                        residents.append(id)
                    }
                }
                let location = Location(id: result.id,
                                        name: result.name,
                                        type: result.type,
                                        dimension: result.dimension,
                                        residents: residents)
                locations.append(location)
            }
        }
        
        return locations
    }
}
