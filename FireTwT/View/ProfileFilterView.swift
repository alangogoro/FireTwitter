//
//  ProfileFilterView.swift
//  FireTwT
//
//  Created by usr on 2021/2/2.
//

import UIKit

private let reuseIdentifier = "ProfileFilterCell"

protocol ProfileFilterViewDelegate: class {
    /// 透過代理傳達使用者選取了哪一個 CollectionView 的標籤
    func filterView(_ filterView: ProfileFilterView,
                    didSelect indexPath: IndexPath)
}

class ProfileFilterView: UIView {
    
    // MARK: - Properties
    weak var delegate: ProfileFilterViewDelegate?
    
    /* 🔰⭐️ 用程式產生 CollectionView FlowLayout ⭐️🔰 */
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero,  // 初始位置和尺寸都填 0 即可
                                  collectionViewLayout: layout)
        
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        collectionView.register(ProfileFilterCell.self,
                                forCellWithReuseIdentifier: reuseIdentifier)
        addSubview(collectionView)
        collectionView.addConstraintsToFillView(self)
        
        // ➡️ 載入時先選取到 CollectionView 的第一個
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath,
                                  animated: true,
                                  scrollPosition: .left)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int)
    -> Int {
        return ProfileFilterOptions.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) ->
    UICollectionViewCell {
        let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                 for: indexPath) as! ProfileFilterCell
        
        let option = ProfileFilterOptions(rawValue: indexPath.row)
        cell.option = option
        
        return cell
    }
}
// MARK: - UICollectionViewDelegate
extension ProfileFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        delegate?.filterView(self, didSelect: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
/* 🔰⭐️ 遵從 DelegateFlowLayout，在 sizeForItemAt 函式設定 Item 大小 ⭐️🔰 */
extension ProfileFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath)
    -> CGSize {
        let countOfOptions = CGFloat(ProfileFilterOptions.allCases.count)
        return CGSize(width: frame.width / countOfOptions, height: frame.height)
    }
    
    /* ⭐️ 設定 Item 之間的間隔 ⭐️ */
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int)
    -> CGFloat {
        return 0
    }
}
