//
//  PokemonAPIClient.swift
//  PokemonViewerTCA
//
//  Created by Denys Melnykov on 28.09.2025.
//

import Foundation
import ComposableArchitecture

struct PokemonAPIClient {
    ///offset: Int, limit: Int
    var fetchPokemons: @Sendable (_ offset: Int, _ limit: Int) async throws -> [Pokemon]
}

extension PokemonAPIClient: DependencyKey {
    static var liveValue = PokemonAPIClient { offset, limit in
        let httpClient = URLSessionHTTPClient()
        let listRequest = try PokemonEndpoint.list(offset: offset, limit: limit).makeRequest()
        let (data, response) = try await httpClient.send(listRequest)
        try NetworkingManager.validate(response)
        
        let pokemonFetchURLStrings = try PokemonListResponseMapper.map(data)
        return try await withThrowingTaskGroup(of:  Pokemon.self) { taskGroup in
            for fetchURLString in pokemonFetchURLStrings {
                taskGroup.addTask { [httpClient] in
                    guard let detailURL = URL(string: fetchURLString) else {
                        throw URLError(.badURL)
                    }
                    
                    let request = try PokemonEndpoint.detail(url: detailURL).makeRequest()
                    let (data, response) = try await httpClient.send(request)
                    try NetworkingManager.validate(response)
                    
                    let pokemon = try PokemonDetailResponseMapper.map(data)
                    return pokemon
                }
            }
            
            var pokemons: [Pokemon] = []
            
            for try await pokemon in taskGroup {
                pokemons.append(pokemon)
            }
            
            return pokemons
        }
    }
    
    static var previewValue: PokemonAPIClient {
        PokemonAPIClient {
            offset,
            limit in
            try await Task.sleep(for: .seconds(3))
            return [Pokemon(
                id: 1,
                name: "TestName",
                height: 20,
                weight: 30,
                imageURLString: "https://cdn.pixabay.com/photo/2021/12/26/17/31/pokemon-6895600_1280.png"
            )]
        }
    }
}

extension DependencyValues {
    var pokemonAPIClient: PokemonAPIClient {
        get { self[PokemonAPIClient.self] }
        set { self[PokemonAPIClient.self] = newValue }
    }
}
