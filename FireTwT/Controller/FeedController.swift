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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    
    // MARK: - Selectors
    @objc func handleRefresh() {
        fetchTweets()
    }
    
    // MARK: - API
    func fetchTweets() {
        collectionView.refreshControl?.beginRefreshing()
        
        TweetService.shared.fetchTweets { tweets in
            /* 🔰 針對 Tweet 做時間戳記排序 🔰 */
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
            
            /* ➡️ 先抓取到所有推文來更新頁面
             * 再逐個檢查使用者是否讚過推文來更新 ❤️ 狀態
             * 避免讀取愛心的時間過長 */
            self.checkIfUserLikedTweets()
            
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserLikedTweets() {
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfLikedTweet(tweet) { didLike in
                // didLike 預設是 false，也就不會更新 ❤️ 圖示
                guard didLike == true else { return }
                
                /* ➡️ 當 forEach 迴圈中的 tweet.didLike
                 * 值為 true 時，
                 * 利用具有唯一識別性的 TweetID 在本頁的 tweets 屬性
                 * 中尋找 ID 相符的元素（firstIndex(where: )）
                 * 並將該元素的 didLike 屬性改為 true。
                 * ⚠️❗️此處理是因為本頁有 RefreshControl，一旦原陣列更新
                 * 在執行 checkIfUserLikedTweets 時，就可能因為
                 * 新舊陣列 mismatch 從而導致 index out of range 錯誤 ⚠️❗️ */
                if let index = self.tweets
                    .firstIndex(where: { $0.tweetID == tweet.tweetID }) {
                    self.tweets[index].didLike = true
                }
            }
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
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(handleRefresh),
                                 for: .valueChanged)
        collectionView.refreshControl = refreshControl
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
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        // ➡️ 生成 FlowLayout 的 CollectionView 頁面
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
/* ❗️⭐️ 遵從 CollectionViewDelegateFlowLayout 來自訂
 * item 的大小、間隔 ⭐️❗️ */
extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        
        /* ➡️ 使 CollectionView Item 的大小（尺寸）
         * 能依照 Tweet 的內容作變化 */
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let textHeight = viewModel.measuredSize(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width, height: textHeight + 72)
        
    }
}

// MARK: - TweetCellDelegate
extension FeedController: TweetCellDelegate {
    func handleProfileImageTapped(_ cell: TweetCell) {
        guard let user = cell.tweet?.user else { return }
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        
        let controller = UploadTweetController(user: tweet.user,
                                               config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true)
    }
    
    func handleLikeTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        
        TweetService.shared.likeTweet(tweet: tweet) { (err, ref) in
            /* ⭐️ 由於在 Cell 中的 tweet 設定成
             * 每當 didSet 就會執行 configure() 刷新 cell 的 UI
             * 所以此處只要賦值 cell.tweet 的任一個屬性，cell 便會自己更新 ⭐️ */
            cell.tweet?.didLike.toggle()
            let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            
            // 判斷只有對推文 ❤️ 時，才會發送通知；Unlike 則不會有通知
            guard !tweet.didLike else { return }
            NotificationService.shared
                .uploadNotification(type: .like, tweet: tweet)
        }
    }
}
