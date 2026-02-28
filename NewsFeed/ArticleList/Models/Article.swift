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

struct Article: Identifiable, Decodable {
    let id: UUID = UUID()
    let title: String
    let author: String?
    let source: Source
    let publishedAt: Date
    let description: String?
    let url: URL
    
    struct Source: Decodable {
        let name: String
    }
    
    enum CodingKeys: String, CodingKey {
        case title, author, source, publishedAt, description, url
    }
}
