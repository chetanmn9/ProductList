//
//  ImageFetcherUseCaseProtocol.swift
//  Product
//


import Foundation
import UIKit

class ImageViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    private let url: URL
    
    private static let cache = NSCache<NSURL, UIImage>()
    
    init(url: URL) {
        self.url = url
    }
    
    func loadImage() {
        Task {
            if let cachedImage = Self.cache.object(forKey: url as NSURL) {
                await MainActor.run {
                    self.image = cachedImage
                }
                return
            }

            do {
                let imageDownloaded = try await downloadImage(from: url)
                Self.cache.setObject(imageDownloaded, forKey: url as NSURL)
                
                await MainActor.run {
                    self.image = imageDownloaded
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
    
    private func downloadImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image
    }
}
