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
                        ErrorView(message: error) {
                            Task { await articleListViewModel.loadArticles() }
                        }
                    } else if articleListViewModel.articles.isEmpty {
                        EmptyStateView()
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
                  NavigationLink(destination: Text("data")) {
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

//MARK: - EmptyStateView
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No articles found")
                .font(.headline)
            Text("Check back later for the latest news.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
}


#Preview {
    ArticleListView()
}
