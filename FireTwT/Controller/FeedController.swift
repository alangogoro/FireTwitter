//
//  FeedController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit
import SDWebImage

private let reuseIdentifier = "TweetCell"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    var user: User? {
        didSet { configureLeftBarButton() }
    }
    
    private var tweets = [Tweet]() {
        /* ❗️⭐️ 當此變數被賦值時，呼叫 CollectionView 重新整理 ⭐️❗️
         * ➡️ 初載入頁面時，變數還是空陣列就會被 CollectionView 調用，造成 numberOfItems 回傳是 0
         * 現在為變數加上 didSet 時去呼叫 CollectionView 重整，就會在從網路抓取完資料被賦值以後再執行一次 */
        didSet { collectionView.reloadData() }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
    }
    
    // MARK: - API
    func fetchTweets() {
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        collectionView.register(TweetCell.self,
                                forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        
        /* ⭐️ 為 NavigationItem 加上推特Logo圖片 ⭐️ */
        let titleView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        titleView.contentMode = .scaleAspectFit
        titleView.setDimensions(width: 44, height: 44)
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

// MARK: - UICollectionViewDelegate/DataSource
extension FeedController {
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int)
    -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                 for: indexPath) as! TweetCell
        
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
/* ❗️⭐️ 遵從 CollectionViewDelegateFlowLayout 來自訂
 * item 的大小、間隔 ⭐️❗️ */
extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}

// MARK: - TweetCellDelegate
extension FeedController: TweetCellDelegate {
    func handleProfileImageTapped() {
        let controller = ProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(controller, animated: true)
    }
}
