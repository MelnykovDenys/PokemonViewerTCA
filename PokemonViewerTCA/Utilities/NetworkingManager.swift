//
//  NetworkingManager.swift
//  PokemonViewer
//
//  Created by Denys Melnykov on 26.09.2025.
//

import Foundation

final class NetworkingManager {
    static func validate(_ response: HTTPURLResponse) throws {
        guard (200..<300).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
