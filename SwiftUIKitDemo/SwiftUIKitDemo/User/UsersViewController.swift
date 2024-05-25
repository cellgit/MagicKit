//
//  UsersViewController.swift
//  SwiftUIKitDemo
//
//  Created by liuhongli on 2024/5/25.
//

import Foundation
import UIKit
import MagicKit

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var users: [User] = []
    private var userDetails: [UserDetail] = []
    private let tableView = UITableView()
//    private let provider = NetworkProvider<UserAPI>(plugins: [NetworkLoggerPlugin(), ErrorHandlerPlugin(), RetryPlugin()])
    
//    let provider = NetworkProvider<UserAPI>()
    
    let provider = NetworkProvider<UserAPI>(plugins: [NetworkLoggerPlugin()])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Users"
        view.backgroundColor = .white
        setupTableView()
        fetchData()
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    private func fetchData() {
        let parser1 = JSONDataParser<[User]>()
        let parser2 = JSONDataParser<[UserDetail]>()
        
        provider.zip(.getUsers, parser1: parser1, .getUserDetails, parser2: parser2) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (users, userDetails)):
                    self?.users = users
                    self?.userDetails = userDetails
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }
    
    private func handleError(_ error: NetworkError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        let detailVC = UserDetailViewController(user: user)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
