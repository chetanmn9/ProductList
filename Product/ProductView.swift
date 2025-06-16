//
//  ContentView.swift
//  Product
//

import SwiftUI

// MARK: - View

struct ProductView: View {
    @StateObject private var viewModel: ProductViewModel
    
    init(viewModel: ProductViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else if viewModel.filteredCategories.isEmpty {
                    emptyStateView
                } else {
                    contentList
                }
            }
            .navigationTitle("Products by Category")
            .searchable(text: $viewModel.searchText)
            .refreshable {
                await viewModel.loadData()
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Loading products...")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Failed to load products")
                .font(.headline)
            Text(error)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            Button("Retry") {
                Task { await viewModel.loadData() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("No products available")
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var contentList: some View {
        List {
            ForEach(viewModel.filteredCategories) { category in
                Section(header: Text(category.name).font(.headline)) {
                    ForEach(category.products) { product in
                        HStack(alignment: .top) {
                            if let url = product.imageURL {
                                let viewModel = ImageViewModel(url: url)
                                ImageView(viewModel: viewModel)
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)
                            }
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(product.title)
                                        .font(.body)
                                    Spacer()
                                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                                        .foregroundColor(.red)
                                        .onTapGesture {
                                            viewModel.toggleFavorite(for: product)
                                        }
                                }
                                Text(product.brand)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("$\(product.price, specifier: "%.2f")")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    let dataManager = DataManager()
    let viewModel = ProductViewModel(manager: dataManager)
    ProductView(viewModel: viewModel)
}
