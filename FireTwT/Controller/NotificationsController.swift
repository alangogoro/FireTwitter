//
//  NotificationsController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationsController: UITableViewController {
    
    // MARK: - Properties
    private var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchNotifications()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /* ➡️ 維持導覽列在換頁、返回之後依然顯示，而不會自動隱藏起來  */
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Selectors
    @objc func handleRefresh() {
        fetchNotifications()
    }
    
    // MARK: - API
    func fetchNotifications() {
        // ➡️ 顯示轉動中的 RefreshControl
        refreshControl?.beginRefreshing()
        
        NotificationService.shared.fetchNotifications { notifications in
            self.notifications = notifications
            // ➡️ 結束並藏起 RefreshControl
            self.refreshControl?.endRefreshing()
            
            for (index, notification) in notifications.enumerated() {
                // ➡️ 如果通知的類型為 .follow
                if case .follow = notification.type {
                    // ➡️ 查詢是否追蹤過 user，並反映在「Follow」按鈕上
                    let user = notification.user
                    UserService.shared.checkIfFollowing(uid: user.uid) { isFollowed in
                        self.notifications[index].user.isFollowed = isFollowed
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self,
                           forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        /* ⭐️ 設置 TableView RefreshControl ⭐️ */
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self,
                                 action: #selector(handleRefresh),
                                 for: .valueChanged)
    }

}

// MARK: - TableViewDataSource
extension NotificationsController {
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int)
    -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: reuseIdentifier,
                                 for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
}
// MARK: - TableViewDelegate
extension NotificationsController {
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        guard let tweetID = notification.tweetID else { return }
        TweetService.shared.fetchTweet(withTweetID: tweetID) { tweet in
            let controller = TweetController(tweet: tweet)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - NotificationCellDelegate
extension NotificationsController: NotificationCellDelegate {
    func didTapFollow(_ cell: NotificationCell) {
        print("======= 🔘 DEBUG: Handle follow tap..")
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                cell.notification?.user.isFollowed = false
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (err, ref) in
                cell.notification?.user.isFollowed = true
            }
        }
    }
    
    func didTapProfileImage(_ cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}
