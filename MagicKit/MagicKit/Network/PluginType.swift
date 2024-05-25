//
//  PluginType.swift
//  MagicKit
//
//  Created by liuhongli on 2024/5/25.
//

// 插件接口定义

import Foundation

public protocol PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest
    func willSend(_ request: URLRequest, target: TargetType)
    func didReceive(_ result: Result<Data, NetworkError>, target: TargetType)
    func didFail(_ error: NetworkError, target: TargetType)
}
