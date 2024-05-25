//
//  NetworkLoggerPlugin.swift
//  MagicKit
//
//  Created by liuhongli on 2024/5/25.
//

// 日志记录插件实现

import Foundation

public class NetworkLoggerPlugin: PluginType {
    
    public init() {}
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return request
    }
    
    public func willSend(_ request: URLRequest, target: TargetType) {
        print("Sending request: \(request.url?.absoluteString ?? "")")
    }
    
    public func didReceive(_ result: Result<Data, NetworkError>, target: TargetType) {
        switch result {
        case .success(let data):
            print("Received data: \(String(data: data, encoding: .utf8) ?? "")")
        case .failure(let error):
            print("Received error: \(error.localizedDescription)")
        }
    }
    
    public func didFail(_ error: NetworkError, target: TargetType) {
        print("Request failed: \(error.localizedDescription)")
    }
}
