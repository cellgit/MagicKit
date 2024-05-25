//
//  UserDetailViewController.swift
//  SwiftUIKitDemo
//
//  Created by liuhongli on 2024/5/25.
//

import UIKit

class UserDetailViewController: UIViewController {
    private let user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = user.name
        view.backgroundColor = .white
        
        let emailLabel = UILabel()
        emailLabel.text = "Email: \(String(describing: user.email))"
        emailLabel.frame = view.bounds
        emailLabel.textAlignment = .center
        
        view.addSubview(emailLabel)
    }
}
