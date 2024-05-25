//
//  UserAPI.swift
//  SwiftDemo
//
//  Created by liuhongli on 2024/5/25.
//

import Foundation
import MagicKit

enum UserAPI {
    case getUsers
    case getUser(id: Int)
    case createUser(name: String, email: String)
    case updateUser(id: Int, name: String, email: String)
    case deleteUser(id: Int)
    case getUserDetails
}

extension UserAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://jsonplaceholder.typicode.com")!
    }
    
    var path: String {
        switch self {
        case .getUsers:
            return "/users"
        case .getUser(let id):
            return "/users/\(id)"
        case .createUser:
            return "/users"
        case .updateUser(let id):
            return "/users/\(id)"
        case .deleteUser(let id):
            return "/users/\(id)"
        case .getUserDetails:
            return "/user/detail"
                
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUsers, .getUser:
            return .get
        case .createUser:
            return .post
        case .updateUser:
            return .put
        case .deleteUser:
            return .delete
        case .getUserDetails:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getUsers, .getUser:
            return .requestPlain
        case .createUser(let name, let email), .updateUser(_, let name, let email):
            return .requestParameters(parameters: ["name": name, "email": email], encoding: .json)
        case .deleteUser:
            return .requestPlain
        case .getUserDetails:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}

