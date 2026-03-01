//
//  ArticleListViewModel.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 28. 2. 2026..
//

import Foundation
import Observation


@Observable class ArticleListViewModel {
    // MARK: - Private Properties
    @ObservationIgnored private var refreshTask: Task<Void, Never>?

    // MARK: - Published State
    var articles: [Article] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String? = nil
    
    // MARK: - Pagination
    private var currentPage = 1
    private var totalResults = 0
    private var hasMorePages: Bool {
        articles.count < totalResults
    }
    
    // MARK: - Dependencies
    private let repository: ArticleRepositoryProtocol
    
    init(repository: ArticleRepositoryProtocol = ArticleRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func loadArticles() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        defer { isLoading = false }
        do {
            let result = try await repository.fetchArticles(page: currentPage)
            articles = result.articles
            totalResults = result.totalResults
            
        #if DEBUG
            print("Loaded \(articles)")
        #endif
        } catch {
            errorMessage = error.localizedDescription
        #if DEBUG
            print("loadArticles failed: \(error)")
        #endif
        }
        
    }
    
    func loadMoreIfNeeded(currentArticle: Article) async {
        guard
            !isLoadingMore,
            hasMorePages,
            let last = articles.last,
            last.id == currentArticle.id
        else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            let result = try await repository.fetchArticles(page: currentPage)
            articles.append(contentsOf: result.articles)
            totalResults = result.totalResults
        } catch {
            currentPage -= 1
        }
        
        isLoadingMore = false
    }
    
    func refresh() async {
        refreshTask?.cancel()
        refreshTask = Task {
            await loadArticles()
        }
        await refreshTask?.value
        refreshTask = nil
    }
}
