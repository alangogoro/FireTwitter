//
//  FeedController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit
import SDWebImage

class FeedController: UIViewController {
    
    // MARK: - Properties
    var user: User? {
        didSet { configureLeftBarButton() }
    } 
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        /* ⭐️ 為 NavigationItem 加上推特Logo圖片 ⭐️ */
        let titleView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        titleView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleView
        
    }
    
    func configureLeftBarButton() {
        guard let user = user else { return }
        
        let profileImageView = UIImageView()
        profileImageView.setDimensions(width: 32, height: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        
        /* ⭐️ 設定 BarButtonItem 成大頭貼 ImageView ⭐️ */
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(customView: profileImageView)
    }
}
