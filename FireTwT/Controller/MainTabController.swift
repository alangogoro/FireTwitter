//
//  MainTabController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit
import Firebase

enum ActionButtonConfiguration {
    case tweet
    case message
}

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    var user: User? {
        /* ⭐️ 把 TabController 得到的 user 指派給 FeedController ⭐️ */
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            guard let feed = nav.viewControllers.first as? FeedController else { return }
            feed.user = user
        }
    }
    private var buttonConfig: ActionButtonConfiguration = .tweet
    
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
        view.backgroundColor = .twitterBlue
        
        authenticateUserAndConfigureUI()
        /* ❗️⭐️ 指定 TabBarControllerDelegate 的代理是自己 ⭐️❗️ */
        self.delegate = self
    }
    
    // MARK: - API
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
                print("===== 🔘 DEBUG: User is NOT logged in")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                // ⭐️ 呈現方式需為全螢幕，避免使用者以手勢下滑方式 dismiss 登入頁面（繞過登入）
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } else {
            configureViewControllers()
            configureUI()
            fetchUser()
            print("===== ✅ DEBUG: User is logged in")
        }
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    // MARK: - Selectors
    @objc func actionButtonTapped() {
        
        let controller: UIViewController
        
        switch buttonConfig {
        case .tweet:
            controller = SearchController(config: .userSearch)
        case .message:
            /* ➡️ 因為有自定義 UploadTweetController 的建構式
             * 在建立該頁面時需要傳入參數 user */
            guard let user = user else { return }
            controller = UploadTweetController(user: user, config: .tweet)
        }
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    // MARK: - Helpers
    func configureViewControllers() {
        /* ❗️⭐️ 初始化 FlowLayout 的 CollectionViewController ⭐️❗️ */
        let feed   = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        let search = SearchController(config: .userSearch)
        let notis  = NotificationsController()
        let convs  = ConversationsController()
        
        let nav0 = templateNavigationController(imageName: "home_unselected",
                                                rootVC: feed)
        let nav1 = templateNavigationController(imageName: "search_unselected",
                                                rootVC: search)
        let nav2 = templateNavigationController(imageName: "like_unselected",
                                                rootVC: notis)
        let nav3 = templateNavigationController(imageName: "ic_mail_outline_2x",
                                                rootVC: convs)
        viewControllers = [nav0, nav1, nav2, nav3]
    }
    
    func configureUI() {
        view.addSubview(actionButton)
        
        /* ❗️view.safeAreaLayoutGuide
         * 相較於 view，SafeArea 會適應各種尺寸的哀鳳螢幕，確保 UI 元件可以完整可見❗️ */
        actionButton.layer.cornerRadius = 56 / 2
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor,
                            right: view.rightAnchor,
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

// MARK: - UITabBarControllerDelegate
/* ⭐️ 遵從 TabBarControllerDelegate 才能取用使用者點選的 Tab 資訊 ⭐️
 * 此處已設定 tabBarControllerDelegate = self */
extension MainTabController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController,
                          didSelect viewController: UIViewController) {
        /* ➡️ 找出被選取的 viewController 在 TabBarController 中的索引編號 */
        let index = viewControllers?.firstIndex(of: viewController)
        
        let imageName = index == 3 ? "mail" : "new_tweet"
        actionButton.setImage(UIImage(named: imageName), for: .normal)
        
        buttonConfig = index == 3 ? .message : .tweet
    }
}
