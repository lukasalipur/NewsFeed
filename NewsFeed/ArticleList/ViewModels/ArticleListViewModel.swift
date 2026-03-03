//
//  ArticleListViewModel.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 28. 2. 2026..
//

import Foundation
import Observation


@MainActor
@Observable class ArticleListViewModel {
    // MARK: - Private Properties
    @ObservationIgnored private var refreshTask: Task<Void, Never>?
    
    // MARK: - Published State
    var articles: [Article] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String? = nil
    var loadMoreError: String? = nil
    var isShowingStaleData = false
    
    // MARK: - Pagination
    private var currentPage = 1
    private var totalResults = 0
    private var hasMorePages: Bool {
        articles.count < totalResults
    }
    
    // MARK: - Dependencies
    private let repository: ArticleRepositoryProtocol
    private let cache: ArticleCacheServiceProtocol
    
    init(
        repository: ArticleRepositoryProtocol = ArticleRepository(),
        cache: ArticleCacheServiceProtocol = ArticleCacheService()
    ) {
        self.repository = repository
        self.cache = cache
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
            cache.save(articles)
            #if DEBUG
            print("Loaded page \(currentPage), total: \(articles.count)/\(totalResults)")
            #endif
            
        } catch {
            guard !error.isCancellation else { return }
            articles = []
            totalResults = 0
            let cached = cache.load()
            if !cached.isEmpty {
                articles = cached
                isShowingStaleData = true
                #if DEBUG
                print("Loading cached articles")
                #endif
            } else {
                articles = []
                totalResults = 0
            }
            errorMessage = AppError(from: error).userMessage
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
        loadMoreError = nil
        defer { isLoadingMore = false }
        
        currentPage += 1
        
        do {
            let result = try await repository.fetchArticles(page: currentPage)
            articles.append(contentsOf: result.articles)
            totalResults = result.totalResults
            
            #if DEBUG
            print("Loaded page \(currentPage), total: \(articles.count)/\(totalResults)")
            #endif
            
        } catch {
            currentPage -= 1
            guard !error.isCancellation else { return }
            loadMoreError = AppError(from: error).userMessage
            
            #if DEBUG
            print("loadMoreIfNeeded failed on page \(currentPage + 1): \(error)")
            #endif
        }
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


// MARK: - Error + Cancellation Helper
private extension Error {
    var isCancellation: Bool {
        (self as? CancellationError) != nil ||
        (self as? URLError)?.code == .cancelled
    }
}
