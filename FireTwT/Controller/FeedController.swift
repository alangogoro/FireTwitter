//
//  FeedController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit

class FeedController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        /* ⭐️ 為 NavigationItem 加上圖片 ⭐️ */
        let titleView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        titleView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleView
    }
}
