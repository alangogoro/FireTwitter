//
//  TweetHeader.swift
//  FireTwT
//
//  Created by usr on 2021/2/22.
//

import UIKit
import SnapKit

/* ⭐️🔰 CollectionReusableView 🔰⭐️
 * 使用於 CollectionView 的 Header 類別 */
class TweetHeader: UICollectionReusableView {
    
    // MARK: - Properities
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        iv.backgroundColor = .twitterBlue
        
        /* ⭐️ 為 ImageView 加上觸碰手勢，便能像 Button 一樣觸發 ⭐️
         * ❗️ 但要宣告為 lazy var */
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleProfileImageTapped))
        // ➡️ 允歲 ImageView 接收互動事件
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Loading"
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "@please wait"
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.text = "Some caption text or string will be shown in this blank beautiful area"
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "10:23 PM - 2/21/2021"
        return label
    }()
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "down_arrow_24pt"), for: .normal)
        button.addTarget(self, action: #selector(handleActionSheet), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0 Retweets"
        return label
    }()
    
    private lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0 Likes"
        return label
    }()
    
    private lazy var statsView: UIView = {
        let view = UIView()
        
        let divider1 = UIView()
        divider1.backgroundColor = .systemGroupedBackground
        view.addSubview(divider1)
        divider1.anchor(top: view.topAnchor,
                        left: view.leftAnchor, right: view.rightAnchor,
                        paddingLeft: 8, height: 1.0)
        
        let stack = UIStackView(arrangedSubviews: [retweetsLabel,
                                                   likesLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.centerY(inView: view)
        stack.anchor(left: view.leftAnchor, paddingLeft: 16)
        
        let divider2 = UIView()
        divider2.backgroundColor = .systemGroupedBackground
        view.addSubview(divider2)
        divider2.anchor(left: view.leftAnchor,
                        bottom: view.bottomAnchor,
                        right: view.rightAnchor,
                        paddingLeft: 8, height: 1.0)
        
        return view
    }()
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let nameStack = UIStackView(arrangedSubviews: [fullnameLabel,
                                                       usernameLabel])
        nameStack.axis = .vertical
        nameStack.spacing = -6
        
        let stack = UIStackView(arrangedSubviews: [profileImageView,
                                                   nameStack])
        stack.spacing = 12
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(16)
            $0.left.right.equalTo(16)
        }
        
        addSubview(captionLabel)
        captionLabel.snp.makeConstraints {
            $0.top.equalTo(stack.snp.bottom).offset(20)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(captionLabel.snp.bottom).offset(20)
            $0.left.equalTo(16)
        }
        
        addSubview(optionsButton)
        optionsButton.snp.makeConstraints {
            $0.centerY.equalTo(stack)
            $0.right.equalToSuperview().inset(8)
        }
        
        addSubview(statsView)
        statsView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(20)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleProfileImageTapped() {
        print("======= DEBUG: Go to User Profile")
    }
    
    @objc func handleActionSheet() {
        print("======= DEBUG: Handle show action sheet")
    }
    
    // MARK: - Helpers
    
}
