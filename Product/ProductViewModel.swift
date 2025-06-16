//
//  ProductViewModel.swift
//  Product
//

import SwiftUI

// MARK: - ViewModel

@MainActor
class ProductViewModel: ObservableObject {
    @Published var categories: [CategoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var favoriteIDs: Set<Int> = []
    
    private let manager: DataManagerProtocol
    
    init(manager: DataManagerProtocol) {
        self.manager = manager
    }
    
    var filteredCategories: [CategoryItem] {
        guard !searchText.isEmpty else { return categories }
        return categories.compactMap { category in
            let filtered = category.products.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
            return filtered.isEmpty ? nil : CategoryItem(id: category.id, name: category.name, products: filtered)
        }
    }
    
    func toggleFavorite(for product: ProductItem) {
        if favoriteIDs.contains(product.id) {
            favoriteIDs.remove(product.id)
        } else {
            favoriteIDs.insert(product.id)
        }
        
        categories = categories.map { category in
            let updated = category.products.map { prod in
                prod.id == product.id ? prod.toggledFavorite() : prod
            }
            return CategoryItem(id: category.id, name: category.name, products: updated)
        }
    }
    
    func loadData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let fetched = try await manager.fetchProductsGroupedByCategory()
            categories = fetched.map { category in
                let updated = category.products.map { product in
                    var product = product
                    product.isFavorite = favoriteIDs.contains(product.id)
                    return product
                }
                return CategoryItem(id: category.id, name: category.name, products: updated)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

