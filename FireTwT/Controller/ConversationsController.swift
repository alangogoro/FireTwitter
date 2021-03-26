//
//  ConversationsController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit
import Firebase

class ConversationsController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("===== ⛔️ DEBUG: Failed to Sign out with error \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Messages"
    }
}
