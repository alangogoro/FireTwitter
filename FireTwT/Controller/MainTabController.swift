//
//  MainTabController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    let actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .twitterBlue
        button.tintColor = .white
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        
        button.addTarget(self,
                         action: #selector(actionButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
        configureUI()
        
    }
    
    // MARK: - Selectors
    @objc func actionButtonTapped() {
        print("ActionButton Tapped!! 🔰🚧➡️⭐️⚠️❗️")
    }
    
    // MARK: - Helpers
    func configureViewControllers() {
        
        let feed   = FeedController()
        let explor = ExploreController()
        let notis  = NotificationsController()
        let convs  = ConversationsController()
        
        let nav0 = templateNavigationController(imageName: "home_unselected",
                                                rootVC: feed)
        let nav1 = templateNavigationController(imageName: "search_unselected",
                                                rootVC: explor)
        let nav2 = templateNavigationController(imageName: "like_unselected",
                                                rootVC: notis)
        let nav3 = templateNavigationController(imageName: "ic_mail_outline_2x",
                                                rootVC: convs)
        viewControllers = [nav0, nav1, nav2, nav3]
        
    }
    
    func configureUI() {
        view.addSubview(actionButton)
        
        /* ❗️view.safeAreaLayoutGuide
         * 相較於 view，SafeArea 會適應各種尺寸的哀鳳螢幕，確保 UI 元件可以完整可見 */
        actionButton.layer.cornerRadius = 56 / 2
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor,
                            paddingBottom: 64, paddingRight: 16,
                            width: 56, height: 56)
    }
    
    func templateNavigationController(imageName: String,
                                      rootVC: UIViewController)
    -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootVC)
        nav.tabBarItem.image = UIImage(named: imageName)
        nav.navigationBar.barTintColor = .white
        return nav
    }
}
