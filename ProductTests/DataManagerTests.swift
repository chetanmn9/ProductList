//
//  ProductTests.swift
//  ProductTests
//

@testable import Product
import XCTest

// MARK: - Unit Test

@MainActor
final class DataManagerTests: XCTestCase {

    var mockSession: MockURLSession!
    var dataManager: DataManager!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        dataManager = DataManager(session: mockSession)
    }

    override func tearDown() {
        mockSession = nil
        dataManager = nil
        super.tearDown()
    }

    func test_fetchProductsGroupedByCategory_success() async throws {
        let categoryURL = URL(string: "https://dummyjson.com/products/categories")!
        let productURL1 = URL(string: "https://dummyjson.com/products/category/smartphones")!
        let productURL2 = URL(string: "https://dummyjson.com/products/category/laptops")!

        let categoriesData = """
        [
          {"slug": "smartphones", "name": "Smartphones", "url": "dummy.com/smartphones"},
          {"slug": "laptops", "name": "Laptops", "url": "dummy.com/laptops"}
        ]
        """.data(using: .utf8)!

        let smartphonesData = """
        {
          "products": [
            {
              "id": 1,
              "title": "iPhone 15",
              "price": 999.99,
              "brand": "Apple",
              "thumbnail": "https://cdn.dummyjson.com/iphone.jpg",
              "category": "smartphones",
              "stock": 50
            }
          ],
          "total": 1,
          "skip": 0,
          "limit": 30
        }
        """.data(using: .utf8)!

        let laptopsData = """
        {
          "products": [
            {
              "id": 2,
              "title": "MacBook Pro",
              "price": 1999.99,
              "brand": "Apple",
              "thumbnail": "https://cdn.dummyjson.com/macbook.jpg",
              "category": "laptops",
              "stock": 20
            }
          ],
          "total": 1,
          "skip": 0,
          "limit": 30
        }
        """.data(using: .utf8)!

        mockSession.setResponse(for: categoryURL,
                                data: categoriesData,
                                response: HTTPURLResponse(url: categoryURL, statusCode: 200, httpVersion: nil, headerFields: nil),
                                error: nil)

        mockSession.setResponse(for: productURL1,
                                data: smartphonesData,
                                response: HTTPURLResponse(url: productURL1, statusCode: 200, httpVersion: nil, headerFields: nil),
                                error: nil)

        mockSession.setResponse(for: productURL2,
                                data: laptopsData,
                                response: HTTPURLResponse(url: productURL2, statusCode: 200, httpVersion: nil, headerFields: nil),
                                error: nil)

        let result = try await dataManager.fetchProductsGroupedByCategory()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Laptops")
        XCTAssertEqual(result[1].name, "Smartphones")
        XCTAssertEqual(result[0].products.first?.title, "MacBook Pro")
        XCTAssertEqual(result[1].products.first?.title, "iPhone 15")
    }

    func test_fetchProductsGroupedByCategory_invalidCategoryJSON_throws() async {
        let categoryURL = URL(string: "https://dummyjson.com/products/categories")!
        mockSession.setResponse(for: categoryURL,
                                data: Data("invalid".utf8),
                                response: HTTPURLResponse(url: categoryURL, statusCode: 200, httpVersion: nil, headerFields: nil),
                                error: nil)

        do {
            _ = try await dataManager.fetchProductsGroupedByCategory()
            XCTFail("Expected decoding failure")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }

    func test_fetchProductsGroupedByCategory_productFetchFails_throws() async {
        let categoryURL = URL(string: "https://dummyjson.com/products/categories")!
        let categoriesData = """
        [
          {"slug": "smartphones", "name": "Smartphones", "url": "dummy.com/smartphones"}
        ]
        """.data(using: .utf8)!

        let productURL = URL(string: "https://dummyjson.com/products/category/smartphones")!

        mockSession.setResponse(for: categoryURL,
                                data: categoriesData,
                                response: HTTPURLResponse(url: categoryURL, statusCode: 200, httpVersion: nil, headerFields: nil),
                                error: nil)

        mockSession.setResponse(for: productURL,
                                data: nil,
                                response: nil,
                                error: URLError(.timedOut))

        do {
            _ = try await dataManager.fetchProductsGroupedByCategory()
            XCTFail("Expected error from product fetch")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }

    func test_fetchProductsGroupedByCategory_invalidURL_throws() async {
        let categoryURL = URL(string: "https://dummyjson.com/products/categories")!
        let categoriesData = """
        [
          {"slug": "💥💥💥", "name": "Invalid URL", "url": "dummy.com/invalid"}
        ]
        """.data(using: .utf8)!

        mockSession.setResponse(for: categoryURL,
                                data: categoriesData,
                                response: HTTPURLResponse(url: categoryURL, statusCode: 200, httpVersion: nil, headerFields: nil),
                                error: nil)

        do {
            _ = try await dataManager.fetchProductsGroupedByCategory()
            XCTFail("Expected error for invalid URL")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
}
