//
//  TargetType.swift
//  MagicKit
//
//  Created by liuhongli on 2024/5/25.
//

// 目标类型协议定义

import Foundation

public protocol TargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: Task { get }
    var headers: [String: String]? { get }
}

public enum Task {
    case requestPlain
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
    case uploadMultipart(data: Data, name: String, fileName: String, mimeType: String)
    case download(destination: URL)
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
