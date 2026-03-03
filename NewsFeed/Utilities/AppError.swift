//
//  AppError.swift
//  NewsFeed
//
//  Created by Luka Šalipur on 3. 3. 2026..
//

import Foundation


enum AppError: Error {
    case network(URLError)
    case decoding(DecodingError)
    case server(statusCode: Int)
    case unknown(Error)

    init(from error: Error) {
        switch error {
        case let networkError as NetworkError:
            switch networkError {
            case .requestFailed(let urlError):
                self = .network(urlError)
            case .serverError(let code):
                self = .server(statusCode: code)
            case .decodingFailed(let decodingError):
                self = .decoding(decodingError)
            case .invalidURL, .unknown:
                self = .unknown(networkError)
            }
        case let urlError as URLError:
            self = .network(urlError)
        case let decodingError as DecodingError:
            self = .decoding(decodingError)
        default:
            self = .unknown(error)
        }
    }

    var userMessage: String {
        switch self {
        case .network(let urlError):
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                return "No internet connection. Check your network and try again."
            case .timedOut:
                return urlError.networkUnavailableReason != nil
                    ? "No internet connection. Check your network and try again."
                    : "The request took too long. Please try again."
            case .cannotConnectToHost, .cannotFindHost:
                return "Server is unreachable. Please try again later."
            case .cancelled:
                return "Request was cancelled."
            default:
                return "Failed to load content. Please try again."
            }
        case .decoding:
            return "Something went wrong while reading the data. Please contact support."
        case .server(let code):
            switch code {
            case 401, 403:
                return "Access denied. Check your API key."
            case 404:
                return "Content not found."
            case 429:
                return "Too many requests. Please wait a moment and try again."
            case 500...599:
                return "Server error (\(code)). Please try again later."
            default:
                return "Unexpected server response (\(code))."
            }
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
}
