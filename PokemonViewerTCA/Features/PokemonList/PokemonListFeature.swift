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
        @Presents
        var selectedPokemon: PokemonDetailsFeature.State?
    }
    
    enum Action {
        case fetchPokemons
        case pokemonsFetched([Pokemon])
        case pokemonSelected(Pokemon)
        case toggleFavoritePokemon(Pokemon)
        case fetchedAllData(favorites: Set<Int>, pokemons: [Pokemon])
        case detailsPokemonAction(PresentationAction<PokemonDetailsFeature.Action>)
    }
    
    @Dependency(\.pokemonAPIClient) var pokemonAPIClient
    @Dependency(\.favoriteIDClient) var favoriteIDClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchPokemons:
                return pokemonFetchProcess(for: &state)
            case .pokemonsFetched(let pokemons):
                return fetchedPokemonsProcess(pokemons, for: &state)
            case .pokemonSelected(let pokemon):
                state.selectedPokemon = .init(pokemon: pokemon)
                return .none
            case .toggleFavoritePokemon(let pokemon):
                return toggleFavoritePokemonProcess(pokemon: pokemon,
                                                     for: &state)
            case .fetchedAllData(let favorites, let pokemons):
                return fetchedAllDataProcess(pokemons: pokemons,
                                             favorites: favorites,
                                             for: &state)
            case .detailsPokemonAction(.presented(.toggleFavoritePokemon(let pokemon))):
                return toggleFavoritePokemonProcess(pokemon: pokemon,
                                                     for: &state)
            default:
                return .none
            }
        }
        .ifLet(\.$selectedPokemon, action: \.detailsPokemonAction) {
            PokemonDetailsFeature()
        }
    }
}

extension PokemonListFeature {
    // MARK: pokemonsFetch
    private func pokemonFetchProcess(for state: inout State) -> Effect<Action> {
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
    private func fetchedPokemonsProcess(
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
    private func toggleFavoritePokemonProcess(
        pokemon: Pokemon,
        for state: inout State
    ) -> Effect<Action> {
        let allPokemons = state.allPokemons
        let pokemonID = pokemon.id
        return .run { send in
            await favoriteIDClient.updateFavorite(pokemonID)
            let favoriteIDs = await favoriteIDClient.fetchFavorites()
            await send(.fetchedAllData(favorites: favoriteIDs,
                                       pokemons: allPokemons))
        }
    }
    
    // MARK: fetchedAllData
    private func fetchedAllDataProcess(
        pokemons: [Pokemon],
        favorites: Set<Int>,
        for state: inout State
    ) -> Effect<Action> {
        state.pokemons = mapAllPokemons(pokemons, favoriteIds: favorites)
        state.favoritePokemonsCount = favorites.count
       
        //update details state if need 
        if let selectedPokemonID = state.selectedPokemon?.pokemon.id,
           let updatedPokemon = state.pokemons.first(where: { $0.id == selectedPokemonID }) {
            
            state.selectedPokemon?.pokemon = updatedPokemon
        }
        return .none
    }
    
    private func mapAllPokemons(_ pokemons: [Pokemon],
                                favoriteIds: Set<Int>) -> [Pokemon] {
        return pokemons.map { pokemon in
            pokemon.updateFavoriteStatus(favoriteIds.contains(pokemon.id))
        }
    }
}
