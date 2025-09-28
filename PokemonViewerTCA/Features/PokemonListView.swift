//
//  PokemonListView.swift
//  PokemonViewerTCA
//
//  Created by Denys Melnykov on 28.09.2025.
//

import SwiftUI
import ComposableArchitecture

struct PokemonListView: View {
    
    let store: StoreOf<PokemonListFeature>
    
    var body: some View {
        NavigationStack {
            listView
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if store.isLoading {
                            ProgressView()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.tint)
                            Text("\(store.state.favoritePokemonsCount)")
                        }
                    }
                }
        }
    }
}

extension PokemonListView {
    
    private var listView: some View {
        List(store.pokemons) { pokemon in
            pokemonCellView(pokemon)
                .onTapGesture {
                    store.send(.pokemonSelected(pokemon))
                }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func pokemonCellView(_ pokemon: Pokemon) -> some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: pokemon.imageURLString)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
            } placeholder: {
                ProgressView()
                    .frame(width: 100, height: 100)
            }
            VStack(alignment: .leading, spacing: 20) {
                Text("Name: \(pokemon.name)")
                    .foregroundStyle(.green)
                Text("ID: \(pokemon.id)")
            }
            Spacer(minLength: 0)
            
            Button("", systemImage: pokemon.favoriteIconName) {
                store.send(.toggleFavoritePokemon(pokemon))
            }
            .buttonStyle(.plain)
        }
        .contentShape(.rect)
    }
}
