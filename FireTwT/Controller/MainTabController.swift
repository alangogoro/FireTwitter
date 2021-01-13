//
//  MainTabController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewControllers()
        
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
    
    func templateNavigationController(imageName: String,
                                      rootVC: UIViewController)
    -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootVC)
        nav.tabBarItem.image = UIImage(named: imageName)
        nav.navigationBar.barTintColor = .white
        return nav
    }
}
