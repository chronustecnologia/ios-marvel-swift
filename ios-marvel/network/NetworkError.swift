//
//  NetworkError.swift
//  ios-marvel
//
//  Created by Jose Julio Junior on 10/06/25.
//


import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case noInternet
    case unknown
    
    var message: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .noInternet:
            return "No internet connection"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
