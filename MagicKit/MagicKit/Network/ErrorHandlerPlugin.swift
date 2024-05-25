//
//  ErrorHandlerPlugin.swift
//  MagicKit
//
//  Created by liuhongli on 2024/5/25.
//

/** 错误处理插件实现
 */

import Foundation

public class ErrorHandlerPlugin: PluginType {
    
    public init() {}
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return request
    }
    
    public func willSend(_ request: URLRequest, target: TargetType) {
        // 在发送请求前可以执行的操作
    }
    
    public func didReceive(_ result: Result<Data, NetworkError>, target: TargetType) {
        // 在接收到响应后可以执行的操作
    }
    
    public func didFail(_ error: NetworkError, target: TargetType) {
        logError(error, target: target)
    }
    
    private func logError(_ error: NetworkError, target: TargetType) {
        // 可以将错误信息记录到日志系统，或上报给监控系统
        print("Error occurred for target \(target): \(error.localizedDescription)")
    }
}

