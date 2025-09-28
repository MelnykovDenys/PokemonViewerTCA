# ⚡ Pokemon Viewer (TCA)

This project demonstrates a client-server application built upon **The Composable Architecture (TCA)**. It features a list of Pokémon with dynamic loading upon scrolling (Infinite Scroll) and local persistence for "Favorite" status.

## ✨ Key Features

* **TCA (Swift Composable Architecture):** A clean, testable architecture managed entirely by state.
* **Infinite Scroll (Pagination):** Dynamic loading of data using `offset` and `limit` parameters as the user scrolls.
* **Swift Concurrency:** Uses `async/await` and `TaskGroup` for asynchronous loading the list of Pokémons.
* **State-Driven Navigation:** Navigation to the detail screen is controlled entirely by the state of the parent Reducer.
* **Dependency Injection:** Uses `DependencyValues` to abstract and isolate external concerns like network requests and local storage (`UserDefaults`).

## 🛠️ Project Structure

The project is divided into logical modules following common TCA conventions:

| Module | Description |
| :--- | :--- |
| **`PokemonListFeature`** | The parent Reducer managing the list, pagination, favorites counter, and navigation. |
| **`PokemonDetailsFeature`** | The child Reducer managing the detail screen. |
| **`Clients`** | Contains all abstractions for interacting with the external world. |
| **`PokemonAPIClient`** | Handles network requests to the Pokémon API. |
| **`FavoritesIDClient`** | Encapsulates the logic for saving and retrieving the IDs of favorited Pokémon from `UserDefaults`. |
| **`Models`** | Contains the data structures (`Pokemon`, `PokemonListResponse`, etc.). |

## 🔄 Data Flow and Logic

### 1. Pagination (Infinite Scroll)

1.  **View:** When a list item near the end of the currently loaded list appears on screen, the View sends the **`.fetchPokemons`** action.
2.  **Reducer:** `PokemonListFeature` receives `.fetchPokemons`, checks `state.isLoading` and `state.allPokemonsLoaded`.
3.  **Effect:** A `.run` effect is launched, which calls `pokemonAPIClient.fetchPokemons(offset, limit)`.
4.  **Processing:** Upon successful data retrieval, the **`.pokemonsFetched(pokemons)`** action is sent, which updates `state.currentOffset` and appends the new data to `state.allPokemons`.

### 2. Favorites Synchronization

1.  **Action:** When the "Favorite" button is tapped (on the list or details screen), the action **`.toggleFavoritePokemon(pokemon)`** is sent to the parent Reducer.
2.  **Effect:** An asynchronous effect is launched, calling `favoriteIDClient.updateFavorite(id)` to persist the change in storage.
3.  **Synchronization Point:** After successful persistence, the action **`.fetchedAllData(favorites: pokemons:)`** is sent.
4.  **Update:** The `.fetchedAllData` case serves as the **single synchronization point:** it recalculates the `isFavorite` status for *all* loaded Pokémon and updates **both the list (`state.pokemons`) and the details (`state.selectedPokemon`)**, ensuring both screens show the latest status.

## 🚀 Getting Started

1.  Clone the repository:
    ```bash
    git clone https://github.com/MelnykovDenys/PokemonViewerTCA
    ```
2.  Open the project in Xcode.
3.  Run on a simulator or device.

***
*P.S. This project uses TCA and Swift Concurrency. Requires Xcode 15+ / iOS 17+.*
