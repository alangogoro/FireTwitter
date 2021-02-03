//
//  ProfileHeader.swift
//  FireTwT
//
//  Created by usr on 2021/1/28.
//

import UIKit

/* ⭐️🔰 CollectionReusableView 🔰⭐️ */
class ProfileHeader: UICollectionReusableView {
    // MARK: - Properties
    private let filterBar = ProfileFilterView()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor,
                          paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_white_24dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self,
                         action: #selector(handleDismissal),
                         for: .touchUpInside)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        return iv
    }()
    
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        
        button.addTarget(self,
                         action: #selector(handleEditProfileFollow),
                         for: .touchUpInside)
        return button
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "Loading Full Name.."
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = "@loading username.."
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 3 // ➡️ 限制自我介紹的文字不得超過3行
        label.text = "This is a user bio that will span more than one line for test purpose"
        return label
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
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                             height: 108)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: containerView.bottomAnchor, left: leftAnchor,
                                paddingTop: -24, paddingLeft: 8)
        profileImageView.setDimensions(width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: containerView.bottomAnchor, right: rightAnchor,
                                       paddingTop: 12, paddingRight: 12)
        editProfileFollowButton.setDimensions(width: 100, height: 36)
        editProfileFollowButton.layer.cornerRadius = 36 / 2
        
        // 帳號的個人文字資訊
        let userDetailsStack = UIStackView(arrangedSubviews: [fullnameLabel,
                                                              usernameLabel,
                                                              bioLabel])
        userDetailsStack.axis = .vertical
        userDetailsStack.distribution = .fillProportionally
        /* ⭐️🔰 fillProportionally StackView 內的每個元件皆分配到適合的空間，不受互相牽制 🔰⭐️ */
        userDetailsStack.spacing = 4
        
        addSubview(userDetailsStack)
        userDetailsStack.anchor(top: profileImageView.bottomAnchor,
                                left: leftAnchor, right: rightAnchor,
                                paddingTop: 8,
                                paddingLeft: 12, paddingRight: 12)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                         height: 50)
        filterBar.delegate = self
        
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor,
                             width: frame.width / 3, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc func handleEditProfileFollow() {
        /* 🚧⚠️ ========== 工事なう ========== ⚠️🚧 */
    }
    
    @objc func handleDismissal() {
        /* 🚧⚠️ ========== 工事なう ========== ⚠️🚧 */
    }
    
}


// MARK: - ProfileFilterViewDelegate
extension ProfileHeader: ProfileFilterViewDelegate {
    
    func filterView(_ view: ProfileFilterView, didSelect indexPath: IndexPath) {
        /* ➡️ 先透過 protocol-delegate 的方式取得
         * 標籤頁面中的 collectionView 被選取的 Cell
         * 🔰 CollectionView.cellForItem(at: ) 🔰 */
        guard let cell = view.collectionView
                .cellForItem(at: indexPath) as? ProfileFilterCell
        else { return }
        
        /* ⭐️ 再取得 Cell 的 X軸 座標，讓底下的 X軸 座標動畫移動 ⭐️ */
        let xPosition = cell.frame.origin.x
        UIView.animate(withDuration: 0.3) {
            self.underlineView.frame.origin.x = xPosition
        }
    }
    
}
