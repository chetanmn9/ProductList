//
//  Product.swift
//  Product
//

import SwiftUI

// MARK: - Models

struct ProductItem: Identifiable, Sendable, Equatable {
    let id: Int
    let title: String
    let price: Double
    let brand: String
    let thumbnail: String
    let category: String
    var isFavorite: Bool = false

    var imageURL: URL? {
        URL(string: thumbnail)
    }

    func toggledFavorite() -> ProductItem {
        var updated = self
        updated.isFavorite.toggle()
        return updated
    }
}

struct CategoryItem: Identifiable, Sendable {
    let id: Int
    let name: String
    let products: [ProductItem]
}

struct CategoryInfo: Codable, Identifiable {
    let slug: String
    let name: String
    let url: String
    
    var id: String { slug }
}

struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let brand: String?
    let thumbnail: String?
    let category: String
    let stock: Int?
}

struct ProductResponse: Codable {
    let products: [Product]
    let total: Int?
    let skip: Int?
    let limit: Int?

    private enum CodingKeys: String, CodingKey {
        case products, total, skip, limit
    }
}
