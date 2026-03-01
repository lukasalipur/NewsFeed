//
//  ArticleDetailView.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 1. 3. 2026..
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text(article.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack {
                    Text(article.source.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(article.publishedAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let author = article.author {
                    Text("By \(author)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                if let description = article.description {
                    Text(description)
                        .font(.body)
                }
                
                Spacer()
                
                Link(destination: article.url) {
                    HStack {
                        Spacer()
                        Text("Read full article")
                        Image(systemName: "arrow.up.right")
                        Spacer()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle(article.source.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ArticleDetailView(article: Article(title: "Test", author: "Test", source: Article.Source(name: "test"), publishedAt: Date(), description: "Test", url: URL(string:"htpps://google.com")!))
}
