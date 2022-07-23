//
//  Cloud.swift
//  RickAndMortyAPIDemo
//
//  Created by Jamie McDaniel on 12/16/21.
//

import Foundation

class Cloud {
    
    // MARK: Internal Properties
    
    enum CloudError: Error {
        case noResponse(Error) // There was no response, such as a timeout or no connection.
        case errorResponse(ErrorResponse) // The server returned an ErrorResponse object. This is for the 400-type "user" errors.
        case serverError(Int) // The server returned a 500-type error. We have only the status code.
        case unexpectedResponse
    }
    
    static var sharedCloud = Cloud()
    
    // MARK: Private Properties
        
    private struct Constants {
        static let baseURL = "https://rickandmortyapi.com/api"
    }
    
    // MARK: Init / Deinit
    
    // MARK: Public Methods
    
    /**
     Fetches from the Rick and Morty API the `CharacterResponse` from page 1 and any pages that follow.
     - Returns: An array of `CharacterResponse` for all pages.
     - Throws: Cloud.Error
     */
    func getCharacters() async throws -> [CharacterResponse] {
        let url = URL(string: Constants.baseURL + "/character")!
        return try await getInfoResponses(url)
    }
    
    /**
     Fetches from the Rick and Morty API the `LocationResponse` from page 1 and any pages that follow.
     - Returns: An array of `LocationResponse` for all pages.
     - Throws: Cloud.Error
     */
    func getLocations() async throws -> [LocationResponse] {
        let url = URL(string: Constants.baseURL + "/location")!
        return try await getInfoResponses(url)
    }
    
    /**
     Fetches from the Rick and Morty API the `EpisodeResponse` from page 1 and any pages that follow.
     - Returns: An array of `EpisodeResponse` for all pages.
     - Throws: Cloud.Error
     */
    func getEpisodes() async throws -> [EpisodeResponse] {
        let url = URL(string: Constants.baseURL + "/episode")!
        return try await getInfoResponses(url)
    }
    
    /**
     Fetches from the Rick and Morty API the `CharacterResponse` from page 1 and any pages that follow.
     - Returns: An AsyncStream of `CharacterResponse` for all pages.
     - Throws: Cloud.Error
     */
    func getCharactersStream() -> AsyncStream<CharacterResponse> {
        let url = URL(string: Constants.baseURL + "/character")!
        return getInfoResponseStream(url)
    }
    
    /**
     Fetches from the Rick and Morty API the `LocationResponse` from page 1 and any pages that follow.
     - Returns: An AsyncStream of `LocationResponse` for all pages.
     - Throws: Cloud.Error
     */
    func getLocationsStream() -> AsyncStream<LocationResponse> {
        let url = URL(string: Constants.baseURL + "/location")!
        return getInfoResponseStream(url)
    }
    
    /**
     Fetches from the Rick and Morty API the `EpisodeResponse` from page 1 and any pages that follow.
     - Returns: An AsyncStream of `EpisodeResponse` for all pages.
     - Throws: Cloud.Error
     */
    func getEpisodesStream() -> AsyncStream<EpisodeResponse> {
        let url = URL(string: Constants.baseURL + "/episode")!
        return getInfoResponseStream(url)
    }
    
    /**
     Fetches from the Rick and Morty API the resource at the specified url.
     - Parameter url: The url of the resource you are requesting.
     - Returns: A `Data` struct for the resource.
     - Throws: Cloud.Error
     */
    func getData(_ url: URL) async throws -> Data {
        print(url.absoluteString)
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                throw CloudError.unexpectedResponse
            }
            if httpURLResponse.statusCode == 200 {
                return data
            }
            else {
                throw CloudError.serverError(httpURLResponse.statusCode)
            }
        }
        catch {
            throw CloudError.noResponse(error)
        }
    }
    
    // MARK: Private Methods
    
    // The Rick And Morty API pages its data. It will only return 20 results at a time.
    // So to get all the data, we have to make multiple calls.
    // The `CharacterResponse`, `LocationResponse`, and `EpisodeResponse` all conform to `InfoResponse`.
    // This method returns an `AsyncStream`.
    private func getInfoResponseStream<T: InfoResponse>(_ url: URL) -> AsyncStream<T> {
        AsyncStream<T> { continuation in
            Task {
                var infoResponse: T = try await getInfoResponse(url)
                continuation.yield(infoResponse)
                while let next = infoResponse.info.next, let nextURL = URL(string: next) {
                    infoResponse = try await getInfoResponse(nextURL)
                    continuation.yield(infoResponse)
                }
                continuation.finish()
            }
        }
    }
    
    // This method returns an array.
    private func getInfoResponses<T: InfoResponse>(_ url: URL) async throws -> [T] {
        var infoResponses: [T] = []
        
        // get the first response from the url that was passed in
        var infoResponse: T = try await getInfoResponse(url)
        infoResponses.append(infoResponse)
        
        // if the previous response contains a next url, then get the next response
        while let next = infoResponse.info.next, let nextURL = URL(string:next) {
            infoResponse = try await getInfoResponse(nextURL)
            infoResponses.append(infoResponse)
        }
        
        return infoResponses
    }
    
    // a function to get a single response and decode it
    private func getInfoResponse<T: InfoResponse>(_ url: URL) async throws -> T {
        print(url.absoluteString)
        let urlRequest = URLRequest(url: url)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                throw CloudError.unexpectedResponse
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if httpURLResponse.statusCode == 200, let infoResponse = try? decoder.decode(T.self, from: data) {
                return infoResponse
            }
            else if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw CloudError.errorResponse(errorResponse)
            }
            else {
                throw CloudError.serverError(httpURLResponse.statusCode)
            }
        }
        catch {
            throw CloudError.noResponse(error)
        }
    }
    
}
