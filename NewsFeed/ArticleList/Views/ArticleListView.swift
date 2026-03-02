//
//  ArticleListView.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 28. 2. 2026..
//

import SwiftUI

struct ArticleListView: View {
    @State var articleListViewModel = ArticleListViewModel()
    var body: some View {
        NavigationStack {
            Group {
                if articleListViewModel.isLoading {
                    ProgressView()
                } else if let error = articleListViewModel.errorMessage, articleListViewModel.articles.isEmpty {
                    ArticleStatusView(state: .error(error)) {
                        await articleListViewModel.refresh()
                    }
                } else if articleListViewModel.articles.isEmpty {
                    ArticleStatusView(state: .empty) {
                        await articleListViewModel.refresh()
                    }
                } else {
                    articleList
                }
            }
            .navigationTitle("Top Headlines")
        }
        .task {
            await articleListViewModel.loadArticles()
        }
    }
    
    private var articleList: some View {
        List {
            ForEach(articleListViewModel.articles) { article in
                NavigationLink(destination: ArticleDetailView(article: article)) {
                    ArticleRowView(article: article)
                }
                .task {
                    await articleListViewModel.loadMoreIfNeeded(currentArticle: article)
                }
            }
            
            if articleListViewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await articleListViewModel.refresh()
        }
    }
}

struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            HStack {
                Text(article.source.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(article.publishedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    ArticleListView()
}
