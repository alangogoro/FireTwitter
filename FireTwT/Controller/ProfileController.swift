//
//  ProfileController.swift
//  FireTwT
//
//  Created by usr on 2021/1/28.
//

import UIKit

private let reuseIdentifier = "TweetCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController {
    
    // MARK: - Properties
    private var user: User
       
    /* ⭐️ 藉由 delegate 取得被使用者選取的 Filter(頁籤) ⭐️
     * 再切換 TableView 的 dataSource */
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet { collectionView.reloadData() }
    }
    // 3 個 Filter 各自的資料陣列
    private var tweets = [Tweet]()
    private var likedTweets = [Tweet]()
    private var replies = [Tweet]()
    // ➡️ Filter(頁籤) 的 TableView DataSource
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets: return tweets
        case .replies: return replies
        case .likes: return likedTweets
        }
    }
    
    
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchTweets()
        fetchLikedTweets()
        fetchReplies()
        checkIfFollowing()
        fetchUserStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    
    // MARK: - Selectors
    
    
    // MARK: - API
    func fetchTweets() {
        TweetService.shared.fetchTweets(forUser: user) { tweets in
            self.tweets = tweets
            print("===== ✅ DEBUG: Completed fetch tweets..")
        }
    }
    
    func fetchLikedTweets() {
        TweetService.shared.fetchLikedTweet(forUser: user) { tweets in
            self.likedTweets = tweets
        }
    }
    
    func fetchReplies() {
        TweetService.shared.fetchReplies(forUser: user) { tweets in
            self.replies = tweets
        }
    }

    func checkIfFollowing() {
        UserService.shared.checkIfFollowing(uid: user.uid) { isFollowing in
            self.user.isFollowed = isFollowing
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStates() {
        UserService.shared.fetchUserStates(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    
    // MARK: - Helpers
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        
        /* ❗️⭐️ 強制 CollectionView 不會自動調整位置避開導覽列 ⭐️❗️ */
        collectionView.contentInsetAdjustmentBehavior = .never
        
        /* ⭐️🔰 註冊 CollectionView 的 Header 🔰⭐️ */
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        collectionView.register(TweetCell.self,
                                forCellWithReuseIdentifier: reuseIdentifier)
        
        /* ⭐️ 先取得 TabBar 的高，再設定 CollectionView 的下緣內距 ⭐️ */
        guard let tabHeight = tabBarController?.tabBar
                .frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }
}


// MARK: - UICollectionViewDataSource
extension ProfileController {
    override func collectionView(_ collectionView:
                                    UICollectionView,
                                 numberOfItemsInSection section: Int)
    -> Int {
        return currentDataSource.count
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                 for: indexPath) as! TweetCell
        cell.tweet = currentDataSource[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath)
    -> UICollectionReusableView {
        let header = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind,
                                              withReuseIdentifier: headerIdentifier,
                                              for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: currentDataSource[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLaout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int)
    -> CGSize {
        return CGSize(width: view.frame.width, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        /* ➡️ 使 CollectionView Item 的大小（尺寸）
         * 能依照 Tweet 的內容作變化 */
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        var textHeight = viewModel.measuredSize(forWidth: view.frame.width).height + 72
        
        if currentDataSource[indexPath.row].isReply {
            textHeight += 20
        }
        
        return CGSize(width: view.frame.width, height: textHeight)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleEditProfileFollow(_ header: ProfileHeader) {
        
        if user.isCurrentUser { return }
        
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                print("===== ✅ DEBUG: Did unfollowed user..")
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
        } else {
            UserService.shared.followUser(uid: user.uid) { (ref, err) in
                print("===== ✅ DEBUG: Followed user..")
                self.user.isFollowed = true
                header.editProfileFollowButton.setTitle("Following", for: .normal)
                self.collectionView.reloadData()
                
                NotificationService.shared.uploadNotification(type: .follow,
                                                              user: self.user)
            }
        }
    }
    
    func didSelectFilter(filter: ProfileFilterOptions) {
        self.selectedFilter = filter
    }
}
