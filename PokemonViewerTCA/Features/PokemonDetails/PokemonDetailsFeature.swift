//
//  PokemonDetailsFeature.swift
//  PokemonViewerTCA
//
//  Created by Denys Melnykov on 28.09.2025.
//

import Foundation
import ComposableArchitecture

@Reducer
struct PokemonDetailsFeature {
    
    @ObservableState
    struct State {
        var pokemon: Pokemon
    }
    
    enum Action {
        case toggleFavoritePokemon(Pokemon)
    }
    
}
