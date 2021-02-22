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
        //print("======= ☑️ DEBUG: tweet.caption is " + tweet.caption)
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
}


// MARK: - UICollectionViewDataSource
extension TweetController {
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int)
    -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
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
        return CGSize(width: view.frame.width, height: 350)
    }
    
    /* ⭐️ 設定 Item(Cell) 的尺寸 ⭐️ */
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
    
}
