//
//  NetworkError.swift
//  MagicKit
//
//  Created by liuhongli on 2024/5/25.
//

// 错误类型定义

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error, Data?)
    case serverError(statusCode: Int, data: Data?)
    case clientError(statusCode: Int, data: Data?)
    case networkError(Error)
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error, _):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(let statusCode, _):
            return "Server error with status code: \(statusCode)"
        case .clientError(let statusCode, _):
            return "Client error with status code: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}
