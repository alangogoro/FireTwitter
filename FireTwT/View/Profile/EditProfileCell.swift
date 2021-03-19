//
//  EditProfileCell.swift
//  FireTwT
//
//  Created by usr on 2021/3/19.
//

import UIKit
import SnapKit

protocol EditProfileCellDelegate: class {
    func updateUserInfo(_ cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {
    
    // MARK: - Properites
    var viewModel: EditProfileViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: EditProfileCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var infoTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textAlignment = .left
        tf.textColor = .twitterBlue
        // 設定 TextField 的邊框
        tf.borderStyle = .none
        /* 🔰 設定 TextField Action 🔰
         * 每次文字輸入完畢即呼叫 */
        tf.addTarget(self,
                     action: #selector(handleUpdateInfo),
                     for: .editingDidEnd)
        tf.text = "Test User Attribute"
        return tf
    }()
    
    let bioTextView: InputTextView = {
        let tv = InputTextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.textColor = .twitterBlue
        tv.placeholderLabel.text = "Bio"
        return tv
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        
        /* ⭐️ 取消 Cell 被選取的樣式 ⭐️ */
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(12)
            $0.left.equalTo(16)
            $0.width.equalTo(100)
        }
        
        contentView.addSubview(infoTextField)
        infoTextField.snp.makeConstraints {
            $0.top.equalTo(4)
            $0.left.equalTo(titleLabel.snp.right).offset(16)
            $0.right.equalTo(8)
            $0.bottom.equalTo(0)
        }
        
        contentView.addSubview(bioTextView)
        bioTextView.snp.makeConstraints {
            $0.top.equalTo(4)
            $0.left.equalTo(titleLabel.snp.right).offset(14)
            $0.right.equalTo(8)
            $0.bottom.equalTo(0)
        }
        
        /* ⭐️ 監聽 TextView 完成編輯 ⭐️ */
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleUpdateInfo),
                                               name: UITextView.textDidEndEditingNotification,
                                               object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleUpdateInfo() {
        delegate?.updateUserInfo(self)
    }
    
    // MARK: - Helpers
    func configure() {
        guard let viewModel = viewModel else { return }
        
        infoTextField.isHidden = viewModel.shouldHideTextField
        bioTextView.isHidden = viewModel.shouldHideTextView
        
        titleLabel.text = viewModel.titleText
        
        infoTextField.text = viewModel.optionValue
        bioTextView.placeholderLabel.isHidden = viewModel.shouldHidePlaceholder
        bioTextView.text = viewModel.optionValue
    }
}
