//
//  NetworkService.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 28. 2. 2026..
//

import Foundation

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T
}
final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .makeDefault()) {
        self.session = session
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    func fetch<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let data: Data
        
        do {
            let (responseData, response) = try await session.data(from: url)
            
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.unknown(URLError(.badServerResponse))
            }
            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.serverError(http.statusCode)
            }
            
            data = responseData
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            throw NetworkError.requestFailed(urlError)
        } catch {
            throw NetworkError.unknown(error)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingFailed(decodingError)
        }
    }
}

// MARK: - URLSession default configuration

private extension URLSession {
    static func makeDefault() -> URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = false
        return URLSession(configuration: config)
    }
}

