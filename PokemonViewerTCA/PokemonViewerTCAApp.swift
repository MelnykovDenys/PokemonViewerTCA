//
//  PokemonViewerTCAApp.swift
//  PokemonViewerTCA
//
//  Created by Denys Melnykov on 28.09.2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct PokemonViewerTCAApp: App {
    
    let store = Store(
        initialState: PokemonListFeature.State(),
        reducer: {
            PokemonListFeature()
        }
    )
    
    var body: some Scene {
        WindowGroup {
            PokemonListView(store: store)
                .onAppear {
                    store.send(.fetchPokemons)
                }
        }
    }
}
