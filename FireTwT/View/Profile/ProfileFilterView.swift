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
                    didSelect index: Int)
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
    
    /// 跟隨使用者點選的標籤而橫向移動到該籤下部的藍色底線
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        return view
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
    
    /* 🔰⭐️ layoutSubviews() 會在 init 之後、 ⭐️🔰
     * View 等畫面佈局都確定好以後才執行。
     * 此時取用 frame 屬性必定有正確的值 */
    override func layoutSubviews() {
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor,
                             width: frame.width / 3, height: 2)
        // frame.width 的值在此 func 確定能取得使用者的螢幕畫面
        // 而非 init func 中 frame 的值會是 0
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
        
        /* 🔰 CollectionView.cellForItem(at: ) 🔰 */
        let cell = collectionView.cellForItem(at: indexPath)
        
        /* ⭐️ 再取得 Cell 的 X軸 座標，讓底下的 X軸 座標動畫移動 ⭐️ */
        let xPosition = cell?.frame.origin.x ?? 0
        UIView.animate(withDuration: 0.3) {
            self.underlineView.frame.origin.x = xPosition
        }
        
        // ➡️ 傳達使用者選取的 cell 給 ProfileHeader
        delegate?.filterView(self, didSelect: indexPath.row)
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
