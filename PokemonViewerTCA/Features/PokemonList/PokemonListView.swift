//
//  PokemonListView.swift
//  PokemonViewerTCA
//
//  Created by Denys Melnykov on 28.09.2025.
//

import SwiftUI
import ComposableArchitecture

struct PokemonListView: View {
    
    @Bindable var store: StoreOf<PokemonListFeature>
    
    var body: some View {
        NavigationStack {
            listView
                .toolbar {
                    toolbarContent
                }
                .navigationDestination(
                    item: $store.scope(state: \.selectedPokemon,
                                       action: \.detailsPokemonAction),
                    destination: PokemonDetailsView.init
                )
        }
    }
}

#Preview {
    let store = Store(
        initialState: PokemonListFeature.State(),
        reducer: { PokemonListFeature()
        }
    )
    PokemonListView(
        store: store
    )
    .onAppear {
        store.send(.fetchPokemons)
    }
}

extension PokemonListView {
    
    private var listView: some View {
        List(store.pokemons) { pokemon in
            LazyVStack {
                pokemonCellView(pokemon)
                    .onTapGesture {
                        store.send(.pokemonSelected(pokemon))
                    }
                    .onAppear {
                        if pokemon.id == store.pokemons.last?.id {
                            store.send(.fetchPokemons)
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
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
