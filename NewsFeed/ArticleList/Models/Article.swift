//
//  Article.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 28. 2. 2026..
//

import Foundation

struct NewsAPIResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct Article: Identifiable, Codable {
    let id: UUID = UUID()
    let title: String
    let author: String?
    let source: Source
    let publishedAt: Date
    let description: String?
    let url: URL
    
    struct Source: Codable {
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case title, author, source, publishedAt, description, url
    }
}

#if DEBUG
extension Article {
    static let mock = Article(
        title: "Test Article",
        author: "Test Author",
        source: Source(name: "Test Source"),
        publishedAt: Date(),
        description: "Test description",
        url: URL(string: "https://example.com")!
    )
}
#endif
