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
    private let user: User
    
    private var tweets = [Tweet]() {
        didSet { collectionView.reloadData() }
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
        print("===== ☑️ DEBUG: User is \(user.username)")
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
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileController {
    override func collectionView(_ collectionView:
                                    UICollectionView,
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
        cell.tweet = tweets[indexPath.row]
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
        return CGSize(width: view.frame.width, height: 120)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
    }
}
