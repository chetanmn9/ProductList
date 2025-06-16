//
//  ProductViewModelTests.swift
//  Product
//

@testable import Product
import XCTest

@MainActor
final class ProductViewModelTests: XCTestCase {
    var viewModel: ProductViewModel!
    var mockManager: MockDataManager!
    
    override func setUp() {
        super.setUp()
        mockManager = MockDataManager()
        viewModel = ProductViewModel(manager: mockManager)
    }

    override func tearDown() {
        viewModel = nil
        mockManager = nil
        super.tearDown()
    }

    func testLoadDataSuccess() async {
        // Given
        let product = ProductItem(id: 1, title: "iPhone", price: 999.0, brand: "Apple", thumbnail: "", category: "smartphones")
        let category = CategoryItem(id: 101, name: "Smartphones", products: [product])
        mockManager.result = .success([category])
        
        // When
        await viewModel.loadData()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.categories.count, 1)
        XCTAssertEqual(viewModel.categories.first?.name, "Smartphones")
        XCTAssertEqual(viewModel.categories.first?.products.first?.title, "iPhone")
    }

    func testLoadDataFailure() async {
        // Given
        mockManager.result = .failure(URLError(.badServerResponse))
        
        // When
        await viewModel.loadData()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.categories.isEmpty)
    }

    func testToggleFavoriteAddsAndRemoves() {
        // Given
        let product = ProductItem(id: 1, title: "iPad", price: 799, brand: "Apple", thumbnail: "", category: "tablets")
        let category = CategoryItem(id: 201, name: "Tablets", products: [product])
        viewModel.categories = [category]

        // When - add to favorite
        viewModel.toggleFavorite(for: product)
        XCTAssertTrue(viewModel.favoriteIDs.contains(1))
        XCTAssertTrue(viewModel.categories[0].products[0].isFavorite)

        // When - remove from favorite
        viewModel.toggleFavorite(for: product)
        XCTAssertFalse(viewModel.favoriteIDs.contains(1))
        XCTAssertFalse(viewModel.categories[0].products[0].isFavorite)
    }

    func testFilteredCategoriesEmptySearch() {
        let product = ProductItem(id: 2, title: "MacBook Pro", price: 1999, brand: "Apple", thumbnail: "", category: "laptops")
        let category = CategoryItem(id: 202, name: "Laptops", products: [product])
        viewModel.categories = [category]
        viewModel.searchText = ""

        let result = viewModel.filteredCategories
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.products.count, 1)
    }

    func testFilteredCategoriesWithMatch() {
        let products = [
            ProductItem(id: 3, title: "Galaxy S22", price: 899, brand: "Samsung", thumbnail: "", category: "smartphones"),
            ProductItem(id: 4, title: "iPhone 15", price: 1099, brand: "Apple", thumbnail: "", category: "smartphones")
        ]
        let category = CategoryItem(id: 203, name: "Smartphones", products: products)
        viewModel.categories = [category]
        viewModel.searchText = "iPhone"

        let result = viewModel.filteredCategories
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.products.count, 1)
        XCTAssertEqual(result.first?.products.first?.title, "iPhone 15")
    }

    func testFilteredCategoriesWithNoMatch() {
        let product = ProductItem(id: 5, title: "ThinkPad", price: 1299, brand: "Lenovo", thumbnail: "", category: "laptops")
        let category = CategoryItem(id: 204, name: "Laptops", products: [product])
        viewModel.categories = [category]
        viewModel.searchText = "Surface"

        let result = viewModel.filteredCategories
        XCTAssertEqual(result.count, 0)
    }
}
