//
//  Utilities.swift
//  FireTwT
//
//  Created by usr on 2021/1/14.
//

import UIKit

class Utilities {
    
    func customInputContainer(withImage image: UIImage,
                              textField: UITextField) -> UIView {
        let view = UIView()
        let iv = UIImageView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        iv.image = image
        view.addSubview(iv)
        iv.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                  paddingLeft: 8, paddingBottom: 8)
        iv.setDimensions(width: 24, height: 24)
        
        view.addSubview(textField)
        textField.anchor(left: iv.rightAnchor,
                         bottom: view.bottomAnchor, right: view.rightAnchor,
                         paddingLeft: 8, paddingBottom: 8)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .white
        view.addSubview(separatorView)
        separatorView.anchor(left: view.leftAnchor,
                             bottom: view.bottomAnchor, right: view.rightAnchor,
                             paddingLeft: 8,
                             height: 0.7)
        
        return view
    }
    
    func customTextField(withPlaceholder placeholder: String) -> UITextField {
        let tf = UITextField()
        
        /* ➡️⭐️ 利用 NSAttributedSring 套上 placeholder 的文字樣式 ⭐️
         * Key.foregroundColor: .white */
        tf.attributedPlaceholder =
            NSAttributedString(string: placeholder,
                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        return tf
    }
    
    /**
     建立一個包含2段文字的按鈕
     - Parameter firstPart: 一般樣式文字
     - Parameter secondPart: **粗體樣式文字**
     */
    func attributedButton(_ firstPart: String, _ secondPart: String) -> UIButton {
        let button = UIButton()
        
        let attributedTitle =
            NSMutableAttributedString(string: firstPart,
                                      attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                                   NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: secondPart,
                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                                                    NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }
    
}
