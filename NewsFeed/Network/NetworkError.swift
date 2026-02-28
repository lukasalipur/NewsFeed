//
//  NetworkError.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 28. 2. 2026..
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case serverError(Int)
    case decodingFailed(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:          return "Invalid URL."
        case .serverError(let c):  return "Server error (code \(c))."
        case .decodingFailed:      return "Failed to parse response."
        case .unknown(let e):      return e.localizedDescription
        }
    }
}
