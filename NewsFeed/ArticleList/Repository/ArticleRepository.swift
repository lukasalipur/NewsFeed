//
//  ArticleRepository.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 28. 2. 2026..
//

import Foundation

protocol ArticleRepositoryProtocol {
    func fetchArticles(page: Int) async throws -> (articles: [Article], totalResults: Int)
}

final class ArticleRepository: ArticleRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let pageSize = 10
    private let apiKey = Environment.apiKey

    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchArticles(page: Int) async throws -> (articles: [Article], totalResults: Int) {
        guard let url = try buildURL(page: page) else {
            throw NetworkError.invalidURL
        }
        
        let response = try await networkService.fetch(NewsAPIResponse.self, from: url)
        #if DEBUG
        print("URL: \(url)")
        #endif
        return (response.articles, response.totalResults)
    }
    
    private func buildURL(page: Int) throws -> URL? {
        var components = URLComponents(string: "https://newsapi.org/v2/top-headlines")
        components?.queryItems = [
            .init(name: "country",  value: "us"),
            .init(name: "page",     value: "\(page)"),
            .init(name: "pageSize", value: "\(pageSize)"),
            .init(name: "apiKey",   value: apiKey)
        ]
        return components?.url
    }
}
