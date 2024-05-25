//
//  DataParser.swift
//  MagicKit
//
//  Created by liuhongli on 2024/5/25.
//

/** 数据解析器定义
 */

import Foundation

public protocol DataParser {
    associatedtype Model
    func parse(data: Data) throws -> Model
}

public struct JSONDataParser<Model: Decodable>: DataParser {
    public init() {}
    public func parse(data: Data) throws -> Model {
        let decoder = JSONDecoder()
        return try decoder.decode(Model.self, from: data)
    }
}

public class DataParsingManager {
    static let shared = DataParsingManager()
    
    private init() {}
    
    public func parse<T: DataParser>(data: Data, with parser: T) throws -> T.Model {
        return try parser.parse(data: data)
    }
}
