struct Pokemon {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let imageURLString: String
    var isFavorite: Bool?
    
    var favoriteIconName: String {
        (isFavorite ?? false) ? "star.fill" : "star"
    }
    
    func updateFavoriteStatus(_ isFavorite: Bool) -> Pokemon {
        Pokemon(
            id: id,
            name: name,
            height: height,
            weight: weight,
            imageURLString: imageURLString,
            isFavorite: isFavorite
        )
    }
}

extension Pokemon: Identifiable { }
