//
//  TweetCell.swift
//  FireTwT
//
//  Created by usr on 2021/1/26.
//

import UIKit
import SnapKit

/* ➡️ 當按下 Cell 的大頭貼，需要呼叫代理 FeedController
 * 其中的 NavigationController 去 push 出該帳號的個人資料頁 */
protocol TweetCellDelegate: class {
    func handleProfileImageTapped(_ cell: TweetCell)
}

class TweetCell: UICollectionViewCell {
    
    // MARK: - Properties
    var tweet: Tweet? {
        didSet { configure() }
    }
    
    weak var delegate: TweetCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        iv.backgroundColor = .twitterBlue
        
        /*let button = UIButton(type: .system)
        button.backgroundColor = .clear
        button.setDimensions(width: 48, height: 48)
        button.addTarget(self, action: #selector(handleProfileImageTapped), for: .touchUpInside)
        iv.addSubview(button)*/
        
        /* ⭐️ 為 ImageView 加上觸碰手勢，便能像 Button 一樣觸發 ⭐️
         * ❗️ 但要宣告為 lazy var */
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleProfileImageTapped))
        // ➡️ 允歲 ImageView 接收互動事件
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = "Some test caption"
        return label
    }()
    
    private let infoLabel = UILabel()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self,
                         action: #selector(handleCommentTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "retweet"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self,
                         action: #selector(handleRetweetTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self,
                         action: #selector(handleLikeTapped),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "share"), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self,
                         action: #selector(handleShareTapped),
                         for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview().inset(8)
        }
        
        let stack = UIStackView(arrangedSubviews: [infoLabel,
                                                   captionLabel])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 4
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.text = "Username @user"
        
        let actionStack = UIStackView(arrangedSubviews: [commentButton,
                                                         retweetButton,
                                                         likeButton,
                                                         shareButton])
        actionStack.axis = .horizontal
        actionStack.spacing = 72
        addSubview(actionStack)
        actionStack.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8)
        }
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        addSubview(underlineView)
        underlineView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc func handleCommentTapped() {
        
    }
    
    @objc func handleRetweetTapped() {
        
    }
    
    @objc func handleLikeTapped() {
        
    }
    
    @objc func handleShareTapped() {
        
    }
    
    // MARK: - Helpers
    func configure() {
        guard let tweet = tweet else { return }
        let viewModel = TweetViewModel(tweet: tweet)
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        infoLabel.attributedText = viewModel.userInfoText
        captionLabel.text = tweet.caption
    }
}
