//
//  Cloud.InfoResponse.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 1/4/22.
//

import Foundation

protocol InfoResponse: Codable {
    var info: Info { get }
}

struct Info: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

