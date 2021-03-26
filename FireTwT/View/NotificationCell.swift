//
//  NotificationCell.swift
//  FireTwT
//
//  Created by usr on 2021/3/10.
//

import UIKit
import SnapKit

protocol NotificationCellDelegate: class {
    func didTapProfileImage(_ cell: NotificationCell)
    func didTapFollow(_ cell: NotificationCell)
}

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    var notification: Notification? {
        didSet { configure() }
    }
    
    weak var delegate: NotificationCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 40, height: 40))
        }
        iv.layer.cornerRadius = 40 / 2
        iv.backgroundColor = .twitterBlue
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleProfileImageTapped))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 2
        
        button.addTarget(self,
                         action: #selector(handelFollowTapped),
                         for: .touchUpInside)
        
        return button
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Some test notification message"
        return label
    }()
    
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(arrangedSubviews: [profileImageView,
                                                   notificationLabel])
        stack.spacing = 8
        stack.alignment = .center
        
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.right.equalTo(12)
        }
        
        addSubview(followButton)
        followButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 92, height: 32))
            $0.right.equalToSuperview().inset(12)
        }
        followButton.layer.cornerRadius = 32 / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc func handleProfileImageTapped() {
        print("======= 🔘 DEBUG: Handle ProfileImage tap..")
        delegate?.didTapProfileImage(self)
    }
    
    @objc func handelFollowTapped() {
        print("======= 🔘 DEBUG: Handle follow tap..")
        delegate?.didTapFollow(self)
    }
    
    // MARK: - Helpers
    func configure() {
        guard let notification = notification else { return }
        
        let viewModel = NotificationViewModel(notification: notification)
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        notificationLabel.attributedText = viewModel.notificationText
        
        followButton.isHidden = viewModel.shouldHideFollowButton
        followButton.setTitle(viewModel.followButtonTitle, for: .normal)
    }
}
