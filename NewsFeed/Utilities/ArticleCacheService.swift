//
//  ArticleCacheService.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 3. 3. 2026..
//

import Foundation

protocol ArticleCacheServiceProtocol {
    func save(_ articles: [Article])
    func load() -> [Article]
    func clear()
    var lastUpdated: Date? { get }
}

final class ArticleCacheService: ArticleCacheServiceProtocol {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private enum Keys {
        static let articles    = "cached_articles"
        static let lastUpdated = "cached_articles_date"
    }
    
    func save(_ articles: [Article]) {
        guard let data = try? encoder.encode(articles) else { return }
        UserDefaults.standard.set(data, forKey: Keys.articles)
        UserDefaults.standard.set(Date(), forKey: Keys.lastUpdated)
    }
    
    func load() -> [Article] {
        guard
            let data = UserDefaults.standard.data(forKey: Keys.articles),
            let articles = try? decoder.decode([Article].self, from: data)
        else { return [] }
        return articles
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: Keys.articles)
        UserDefaults.standard.removeObject(forKey: Keys.lastUpdated)
    }
    
    var lastUpdated: Date? {
        UserDefaults.standard.object(forKey: Keys.lastUpdated) as? Date
    }
}
