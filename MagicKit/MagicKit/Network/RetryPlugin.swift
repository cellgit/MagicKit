//
//  RetryPlugin.swift
//  MagicKit
//
//  Created by liuhongli on 2024/5/25.
//

/** 自动重试插件实现
 */
import Foundation

public class RetryPlugin: PluginType {
    
    private let maxRetryCount: Int
    private var retryCount = [String: Int]()
    
    public init(maxRetryCount: Int = 3) {
        self.maxRetryCount = maxRetryCount
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        return request
    }
    
    public func willSend(_ request: URLRequest, target: TargetType) {
        // 在发送请求前可以执行的操作
    }
    
    public func didReceive(_ result: Result<Data, NetworkError>, target: TargetType) {
        // 在接收到响应后可以执行的操作
        guard case .failure = result else {
            resetRetryCount(for: target)
            return
        }
    }
    
    public func didFail(_ error: NetworkError, target: TargetType) {
        let key = target.path
        retryCount[key, default: 0] += 1
        
        if retryCount[key, default: 0] <= maxRetryCount {
            // 重试请求
            // 这里可以调用一个重试机制来重新发送请求
            // 注意：这里需要访问 `NetworkProvider` 来重新发送请求
            // 例如，通过一个委托或闭包来重新发送请求
            print("Retrying request \(target.path)... (\(retryCount[key, default: 0])/\(maxRetryCount))")
        } else {
            resetRetryCount(for: target)
        }
    }
    
    private func resetRetryCount(for target: TargetType) {
        retryCount[target.path] = 0
    }
}
