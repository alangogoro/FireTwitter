//
//  TweetController.swift
//  FireTwT
//
//  Created by usr on 2021/2/22.
//

import UIKit

private let headerIdentifier = "TweetHeader"
private let reuseIdentifier = "TweetCell"

class TweetController: UICollectionViewController {
    
    // MARK: - Properties
    private let tweet: Tweet
    private var replies = [Tweet]() {
        didSet { collectionView.reloadData() }
    }
    
    private var actionSheetLauncher: ActionSheetLauncher!
    
    // MARK: - Lifecycle
    init(tweet: Tweet) {
        self.tweet = tweet
        /* ⭐️ 初始化 CollectionViewController 時，必須呼叫其原始建構式 ⭐️ */
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        fetchReplies()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    
    // MARK: - Helpers
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        
        /* 🔰 註冊 CollectionView 的 Header 和 Cell 🔰 */
        collectionView.register(TweetHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        collectionView.register(TweetCell.self,
                                forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    fileprivate func showActionSheet(forUser user: User) {
        actionSheetLauncher = ActionSheetLauncher(user: user)
        actionSheetLauncher.delegate = self
        actionSheetLauncher.show()
    }
    
    // MARK: - API
    func fetchReplies() {
        TweetService.shared.fetchReplies(forTweet: tweet) { replies in
            self.replies = replies
        }
    }
}


// MARK: - UICollectionViewDataSource
extension TweetController {
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int)
    -> Int {
        return replies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                 for: indexPath) as! TweetCell
        cell.tweet = replies[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TweetController {
    /* ⭐️ 設定 Header 內容 ⭐️ */
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath)
    -> UICollectionReusableView {
        
        let header = collectionView
            .dequeueReusableSupplementaryView(ofKind: kind,
                                              withReuseIdentifier: headerIdentifier,
                                              for: indexPath) as! TweetHeader
        header.tweet = tweet
        header.delegate = self
        return header
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TweetController: UICollectionViewDelegateFlowLayout {
    
    /* ⭐️ 設定 Header 的尺寸 ⭐️ */
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int)
    -> CGSize {
        
        /* ➡️ 使 CollectionView Header 的大小（尺寸）
         * 能依照 Tweet 的內容作變化 */
        let viewModel = TweetViewModel(tweet: tweet)
        let captionHeight = viewModel.measuredSize(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width, height: captionHeight + 260)
    }
    
    /* ⭐️ 設定 Item(Cell) 的尺寸 ⭐️ */
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        /* ➡️ 使 CollectionView Item 的大小（尺寸）
         * 能依照 Reply 的內容作變化 */
        let viewModel = TweetViewModel(tweet: replies[indexPath.row])
        let textHight = viewModel.measuredSize(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width, height: textHight + 66)
    }
}

// MARK: - TweetHeaderDelegate
extension TweetController: TweetHeaderDelegate {
    
    func showActionSheet() {
        if tweet.user.isCurrentUser {
            showActionSheet(forUser: tweet.user)
        } else {
            UserService.shared.checkIfFollowing(uid: tweet.user.uid) { isFollowing in
                var user = self.tweet.user
                user.isFollowed = isFollowing
                
                self.showActionSheet(forUser: user)
            }
        }
    }
}

// MARK: - ActionSheetLauncherDelegate
extension TweetController: ActionSheetLauncherDelegate {
    
    func didSelect(option: ActionSheetOption) {
        switch option {
        case .follow(let user):
            UserService.shared.followUser(uid: user.uid) { (err, ref) in
                print("===== ✅ DEBUG: Did follow user \(user.username)")
            }
        case .unfollow(let user):
            UserService.shared.unfollowUser(uid: user.uid) { (err, ref) in
                print("===== ✅ DEBUG: Did unfollow user \(user.username)")
            }
        case .report:
            print("===== 🔘 DEBUG: Report tweet..")
        case .delete:
            print("===== 🔘 DEBUG: Delete tweet..")
        }
    }
    
}
