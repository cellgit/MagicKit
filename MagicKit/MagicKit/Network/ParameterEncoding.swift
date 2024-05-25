//
//  ParameterEncoding.swift
//  MagicKit
//
//  Created by liuhongli on 2024/5/25.
//

// 参数编码定义

import Foundation

public enum ParameterEncoding {
    case url
    case json
    
    public func encode(_ request: inout URLRequest, with parameters: [String: Any]) throws {
        switch self {
        case .url:
            guard var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
                throw NetworkError.invalidURL
            }
            urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            request.url = urlComponents.url
            
        case .json:
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
