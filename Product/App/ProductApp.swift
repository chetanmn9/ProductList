//
//  ProductApp.swift
//  Product
//
//

import SwiftUI

@main
struct ProductApp: App {
    var body: some Scene {
        WindowGroup {
            let dataManager = DataManager()
            let viewModel = ProductViewModel(manager: dataManager)
            ProductView(viewModel: viewModel)
        }
    }
}
