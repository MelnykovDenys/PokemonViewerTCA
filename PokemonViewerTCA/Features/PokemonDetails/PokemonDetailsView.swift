//
//  PokemonDetailsView.swift
//  PokemonViewerTCA
//
//  Created by Denys Melnykov on 28.09.2025.
//

import SwiftUI
import ComposableArchitecture

struct PokemonDetailsView: View {
    
    var store: StoreOf<PokemonDetailsFeature>
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: store.pokemon.imageURLString)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
            } placeholder: {
                ProgressView()
                    .frame(width: 200, height: 200)
            }
            VStack(alignment: .leading) {
                Text("Parameters: ")
                    .font(.headline)
                parameterText("Name:", store.pokemon.name.uppercased())
                    .foregroundStyle(.green)
                parameterText("ID:", "\(store.pokemon.id)")
                    .foregroundStyle(.red)
                parameterText("Weight:", "\(store.pokemon.weight)")
                    .foregroundStyle(.blue)
                parameterText("Height:", "\(store.pokemon.height)")
                    .foregroundStyle(.cyan)
            }
            .padding(.horizontal)
            Spacer(minLength: 0)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.toggleFavoritePokemon(store.pokemon))
                } label: {
                    Image(systemName: store.state.pokemon.favoriteIconName)
                }
            }
        }
    }
    
    private func parameterText(_ parameter: String, _ value: String) -> some View {
        HStack {
            Text(parameter)
                .fontWeight(.bold)
            Spacer()
            Text(value)
        }
    }
}
