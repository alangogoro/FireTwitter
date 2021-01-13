//
//  ExplorerController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit

class ExploreController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        /* ⭐️ 為 NavigationItem 加上 Title ⭐️ */
        navigationItem.title = "Explore"
    }
}
