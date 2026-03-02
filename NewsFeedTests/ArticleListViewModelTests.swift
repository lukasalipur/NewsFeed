//
//  ArticleListViewModelTests.swift
//  NewsFeedTests
//
//  Created by Luka Šalipur on 2. 3. 2026..
//

import Foundation
import Testing
@testable import NewsFeed

// MARK: - Mock
final class MockArticleRepository: ArticleRepositoryProtocol {
    var result: Result<(articles: [Article], totalResults: Int), Error> = .success(([], 0))
    
    func fetchArticles(page: Int) async throws -> (articles: [Article], totalResults: Int) {
        switch result {
        case .success(let data): return data
        case .failure(let error): throw error
        }
    }
}

// MARK: - Tests
@Suite("ArticleListViewModel Tests")
struct ArticleListViewModelTests {
    
    @Test("Articles are loaded successfully")
    func testLoadArticlesSuccess() async {
        let mock = MockArticleRepository()
        mock.result = .success((articles: [.mock], totalResults: 1))
        
        let viewModel = ArticleListViewModel(repository: mock)
        await viewModel.loadArticles()
        
        #expect(viewModel.articles.count == 1)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Error message is set on failure")
    func testLoadArticlesFailure() async {
        let mock = MockArticleRepository()
        mock.result = .failure(NetworkError.serverError(500))
            
        let viewModel = ArticleListViewModel(repository: mock)
        await viewModel.loadArticles()
        
        #expect(viewModel.articles.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
}
