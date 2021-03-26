//
//  TweetCell.swift
//  FireTwT
//
//  Created by usr on 2021/1/26.
//

import UIKit
import SnapKit
import ActiveLabel

protocol TweetCellDelegate: class {
    // ➡️ 當按下 Cell 的大頭貼，需要呼叫代理 FeedController
    // 其中的 NavigationController 去 push 出該帳號的個人資料頁
    func handleProfileImageTapped(_ cell: TweetCell)
    func handleReplyTapped(_ cell: TweetCell)
    func handleLikeTapped(_ cell: TweetCell)
    func handleFetchUser(withUsername username: String)
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
        
        /* ⭐️ 為 ImageView 加上觸碰手勢，便能像 Button 一樣觸發 ⭐️
         * ❗️ 但要宣告為 lazy var */
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleProfileImageTapped))
        // ➡️ 允許 ImageView 接收互動事件
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.mentionColor = .twitterBlue
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        // ➡️ 設定 ActionLabel 文字顏色
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    
    private let infoLabel = UILabel()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        button.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "retweet")
        button.addTarget(self, action: #selector(handleRetweetTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        button.addTarget(self, action: #selector(handleShareTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        let captionStack = UIStackView(arrangedSubviews: [infoLabel,
                                                          captionLabel])
        captionStack.axis = .vertical
        captionStack.distribution = .fillProportionally
        captionStack.spacing = 4
        
        let stack = UIStackView(arrangedSubviews: [profileImageView,
                                                   captionStack])
        stack.distribution = .fillProportionally
        stack.spacing = 12
        stack.alignment = .leading
        
        let mutableStack = UIStackView(arrangedSubviews: [replyLabel,
                                                          stack])
        mutableStack.axis = .vertical
        mutableStack.spacing = 8
        mutableStack.distribution = .fillProportionally
        
        addSubview(mutableStack)
        mutableStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(12)
        }
        
        replyLabel.isHidden = true
        
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
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
        
        configureMentionHandler()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc func handleProfileImageTapped() {
        delegate?.handleProfileImageTapped(self)
    }
    
    @objc func handleCommentTapped() {
        delegate?.handleReplyTapped(self)
    }
    
    @objc func handleRetweetTapped() {
        
    }
    
    @objc func handleLikeTapped() {
        delegate?.handleLikeTapped(self)
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
        
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
    }
    
    func configureMentionHandler() {
        captionLabel.handleMentionTap { username in
            self.delegate?.handleFetchUser(withUsername: username)
        }
    }
    
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        button.setDimensions(width: 20, height: 20)
        return button
    }
}
