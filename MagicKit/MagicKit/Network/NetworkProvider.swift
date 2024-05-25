//
//  NetworkProvider.swift
//  MagicKit
//
//  Created by liuhongli on 2024/5/25.
//

/** 网络提供者实现
 */

import Foundation

public class NetworkProvider<T: TargetType> {
    private let plugins: [PluginType]
    private let urlSession: URLSession
    
    public init(plugins: [PluginType] = [], urlSession: URLSession = .shared) {
        self.plugins = plugins
        self.urlSession = urlSession
    }
    
    public func request<U: DataParser>(_ target: T, parser: U, completion: @escaping (Result<U.Model, NetworkError>) -> Void) where U.Model: Decodable {
        let url = target.baseURL.appendingPathComponent(target.path)
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        
        do {
            switch target.task {
            case .requestPlain:
                break
            case .requestParameters(let parameters, let encoding):
                try encoding.encode(&request, with: parameters)
            case .uploadMultipart(let data, let name, let fileName, let mimeType):
                let boundary = "Boundary-\(UUID().uuidString)"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = createMultipartBody(data: data, name: name, fileName: fileName, mimeType: mimeType, boundary: boundary)
            case .download(let destination):
                download(request, to: destination, target: target) { result in
                    completion(result.map { _ in () as! U.Model })
                }
                return
            }
        } catch {
            let networkError = NetworkError.unknown(error)
            plugins.forEach { $0.didFail(networkError, target: target) }
            completion(.failure(networkError))
            return
        }
        
        // Apply plugins
        plugins.forEach { request = $0.prepare(request, target: target) }
        plugins.forEach { $0.willSend(request, target: target) }
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            let result: Result<U.Model, NetworkError>
            
            if let error = error as? URLError {
                result = .failure(NetworkError.networkError(error))
            } else if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                result = .failure(NetworkError.serverError(statusCode: httpResponse.statusCode, data: data))
            } else if let data = data {
                do {
                    let parsedData = try DataParsingManager.shared.parse(data: data, with: parser)
                    result = .success(parsedData)
                } catch {
                    result = .failure(NetworkError.decodingError(error, data))
                }
            } else {
                result = .failure(NetworkError.noData)
            }
            
            // Notify plugins
            self.plugins.forEach { $0.didReceive(result.map { $0 as! Data }, target: target) }
            if case .failure(let error) = result {
                self.plugins.forEach { $0.didFail(error, target: target) }
            }
            completion(result)
        }
        
        task.resume()
    }
    
    public func zip<U1: DataParser, U2: DataParser>(
        _ target1: T, parser1: U1,
        _ target2: T, parser2: U2,
        completion: @escaping (Result<(U1.Model, U2.Model), NetworkError>) -> Void
    ) where U1.Model: Decodable, U2.Model: Decodable {
        let group = DispatchGroup()
        
        var result1: Result<U1.Model, NetworkError>?
        var result2: Result<U2.Model, NetworkError>?
        
        group.enter()
        request(target1, parser: parser1) { result in
            result1 = result
            group.leave()
        }
        
        group.enter()
        request(target2, parser: parser2) { result in
            result2 = result
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let result1 = result1, let result2 = result2 {
                switch (result1, result2) {
                case (.success(let model1), .success(let model2)):
                    completion(.success((model1, model2)))
                case (.failure(let error), _):
                    completion(.failure(error))
                case (_, .failure(let error)):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func download(_ request: URLRequest, to destination: URL, target: T, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let task = urlSession.downloadTask(with: request) { location, response, error in
            let result: Result<Data, NetworkError>
            
            if let error = error {
                result = .failure(.networkError(error))
            } else if let location = location {
                do {
                    let data = try Data(contentsOf: location)
                    try FileManager.default.moveItem(at: location, to: destination)
                    result = .success(data)
                } catch {
                    result = .failure(.unknown(error))
                }
            } else {
                result = .failure(.noData)
            }
            
            // Notify plugins
            self.plugins.forEach { $0.didReceive(result, target: target) }
            if case .failure(let error) = result {
                self.plugins.forEach { $0.didFail(error, target: target) }
            }
            completion(result)
        }
        
        task.resume()
    }
    
    private func createMultipartBody(data: Data, name: String, fileName: String, mimeType: String, boundary: String) -> Data {
        var body = Data()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        body.append(boundaryPrefix.data(using: .utf8)!)
        
        body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}

