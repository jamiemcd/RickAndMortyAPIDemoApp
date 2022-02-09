//
//  Cloud.ErrorResponse.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/2/22.
//

import Foundation

extension Cloud {
    struct ErrorResponse: Codable {
        let error: String
    }
}
