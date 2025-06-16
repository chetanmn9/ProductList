//
//  MockDataManager.swift
//  Product
//

import Testing
@testable import Product
import XCTest

@testable import Product

final class MockDataManager: DataManagerProtocol {
    var result: Result<[CategoryItem], Error> = .success([])
    
    func fetchProductsGroupedByCategory() async throws -> [CategoryItem] {
        switch result {
        case .success(let items): return items
        case .failure(let error): throw error
        }
    }
}
