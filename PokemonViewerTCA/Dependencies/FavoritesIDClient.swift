//
//  PokemonFavoritesClient.swift
//  PokemonViewerTCA
//
//  Created by Denys Melnykov on 28.09.2025.
//

import Foundation
import ComposableArchitecture

struct FavoritesIDClient {
    var fetchFavorites: @Sendable () async -> Set<Int>
    var updateFavorite: @Sendable(_: Int) async -> Void
}

extension FavoritesIDClient: DependencyKey {
    static var liveValue: FavoritesIDClient {
        let key = "favorites"
        
        return FavoritesIDClient(fetchFavorites: {
            let ids = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
            return Set(ids)
        }, updateFavorite: { id in
            let idsArray = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
            var ids: Set<Int> = Set(idsArray)
            if ids.contains(id) {
                ids.remove(id)
            } else {
                ids.insert(id)
            }
            UserDefaults.standard.set(Array(ids), forKey: key)
        })
    }
}

extension DependencyValues {
    var favoriteIDClient: FavoritesIDClient {
        get { self[FavoritesIDClient.self] }
        set { self[FavoritesIDClient.self] = newValue }
    }
}
