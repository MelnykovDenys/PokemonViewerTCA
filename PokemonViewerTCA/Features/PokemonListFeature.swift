//
//  PokemonListFeature.swift
//  PokemonViewerTCA
//
//  Created by Denys Melnykov on 28.09.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PokemonListFeature {
    private let fetchLimit: Int = 20
    
    @ObservableState
    struct State {
        var pokemons: [Pokemon] = []
        var isLoading: Bool = false
        var favoritePokemonsCount: Int = 0
        @ObservationStateIgnored
        var allPokemons: [Pokemon] = []
        @ObservationStateIgnored
        var currentOffset: Int = 0
        @ObservationStateIgnored
        var allPokemonsLoaded: Bool = false
    }
    
    enum Action {
        case fetchPokemons
        case pokemonsFetched([Pokemon])
        case pokemonSelected(Pokemon)
        case toggleFavoritePokemon(Pokemon)
        
        case fetchedAllData(favorites: Set<Int>, pokemons: [Pokemon])
    }
    
    @Dependency(\.pokemonAPIClient) var pokemonAPIClient
    @Dependency(\.favoriteIDClient) var favoriteIDClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchPokemons:
                return processPokemonFetch(for: &state)
            case .pokemonsFetched(let pokemons):
                return processFetchedPokemons(pokemons, for: &state)
            case .pokemonSelected(let pokemon):
                debugPrint("selected all cell for \(pokemon.name)")
                return .none
            case .toggleFavoritePokemon(let pokemon):
                return proccessToggleFavoritePokemon(pokemon: pokemon, for: &state)
            case .fetchedAllData(let favorites, let pokemons):
                state.pokemons = mapAllPokemons(pokemons, favoriteIds: favorites)
                state.favoritePokemonsCount = favorites.count
                return .none
            }
        }
    }
}

extension PokemonListFeature {
    // MARK: pokemonsFetch
    private func processPokemonFetch(for state: inout State) -> Effect<Action> {
        guard !state.isLoading,
              !state.allPokemonsLoaded else {
            return .none
        }
        state.isLoading = true
        let offset = state.currentOffset
        return .run { send in
            do {
                let pokemons = try await pokemonAPIClient.fetchPokemons(offset, fetchLimit)
                await send(.pokemonsFetched(pokemons))
            } catch {
                //handle error
                debugPrint(error.localizedDescription)
                await send(.pokemonsFetched([]))
            }
        }
    }
    
    // MARK: pokemonsFetched
    private func processFetchedPokemons(
        _ pokemons: [Pokemon],
        for state: inout State
    ) -> Effect<Action> {
        state.isLoading = false
        if pokemons.count < fetchLimit {
            //infinity request protection but must be agreed with the backend
            state.allPokemonsLoaded = true
        }
        
        state.currentOffset += fetchLimit
        let combinedList = state.allPokemons + pokemons
        state.allPokemons = combinedList
                
        return .run { send in
            let favoriteIDs = await favoriteIDClient.fetchFavorites()
            await send(.fetchedAllData(favorites: favoriteIDs,
                                       pokemons: combinedList))
        }
    }
    
    //MARK: toggleFavoritePokemon
    private func proccessToggleFavoritePokemon(
        pokemon: Pokemon,
        for state: inout State
    ) -> Effect<Action> {
        let allPokemons = state.allPokemons
        return .run { send in
            await favoriteIDClient.updateFavorite(pokemon.id)
            let favoriteIDs = await favoriteIDClient.fetchFavorites()
            await send(.fetchedAllData(favorites: favoriteIDs,
                                       pokemons: allPokemons))
        }
    }
    
    // MARK: Mapping
    private func mapAllPokemons(_ pokemons: [Pokemon],
                                favoriteIds: Set<Int>) -> [Pokemon] {
        return pokemons.map { pokemon in
            pokemon.updateFavoriteStatus(favoriteIds.contains(pokemon.id))
        }
    }
}
