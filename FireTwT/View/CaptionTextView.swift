//
//  CaptionTextView.swift
//  FireTwT
//
//  Created by usr on 2021/1/25.
//

import UIKit

/**
 一個包含灰色提示文字的 TextView
 */
class CaptionTextView: UITextView {
    
    // MARK: - Property
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "What's happening?"
        return label
    }()
    
    // MARK: - Lifecycel
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = .white
        
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = false
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: topAnchor, left: leftAnchor,
                                paddingTop: 8, paddingLeft: 4)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handelTextInputChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selector
    @objc func handelTextInputChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}
