//
//  DataManager.swift
//  Product
//

import Foundation

// MARK: - Data Manager Protocol

protocol DataManagerProtocol: Sendable {
    func fetchProductsGroupedByCategory() async throws -> [CategoryItem]
}

extension DataManager: DataManagerProtocol {}

// MARK: - Data Manager with Actor

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

actor DataManager {
    
    private let session: URLSessionProtocol
        
        init(session: URLSessionProtocol = URLSession.shared) {
            self.session = session
        }

    func fetchProductsGroupedByCategory() async throws -> [CategoryItem] {

        let categoryURL = URL(string: "https://dummyjson.com/products/categories")!
        let (categoryData, _) = try await session.data(from: categoryURL)
        let categoryNames: [CategoryInfo]
        do {
            categoryNames = try JSONDecoder().decode([CategoryInfo].self, from: categoryData)
        } catch {
            throw error
        }

        var results: [CategoryItem] = []

        try await withThrowingTaskGroup(of: CategoryItem.self) { group in
            for categoryName in categoryNames {
                group.addTask {
                    guard let encodedCategory = categoryName.slug.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
                          let productURL = URL(string: "https://dummyjson.com/products/category/\(encodedCategory)") else {
                        throw URLError(.badURL)
                    }
                    let request = URLRequest(url: productURL, timeoutInterval: 10)
                    let (data, response) = try await self.session.data(from: request.url!)
                    
                    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    
                    do {
                        let response = try JSONDecoder().decode(ProductResponse.self, from: data)
                        let products = response.products.map {
                            ProductItem(id: $0.id,
                                        title: $0.title,
                                        price: $0.price,
                                        brand: $0.brand ?? "Unknown",
                                        thumbnail: $0.thumbnail ?? "",
                                        category: $0.category)
                        }
                        return CategoryItem(id: categoryName.slug.hashValue,
                                            name: categoryName.name,
                                            products: products)
                    } catch {
                        throw error
                    }
                }
            }

            for try await item in group {
                results.append(item)
            }
        }
        return results.sorted(by: { $0.name < $1.name })
    }
}
