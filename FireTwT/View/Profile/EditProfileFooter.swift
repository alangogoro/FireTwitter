//
//  EditProfileFooter.swift
//  FireTwT
//
//  Created by usr on 2021/3/23.
//

import UIKit
import SnapKit

protocol EditProfileFooterDelegate: class {
    func handleLogout()
}

class EditProfileFooter: UIView {
    
    // MARK: - Properties
    weak var delegate: EditProfileFooterDelegate?
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 5
        button.addTarget(self,
                         action: #selector(handleLogout),
                         for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(logoutButton)
        logoutButton.snp.makeConstraints {
            $0.left.right.equalTo(self).inset(16)
            $0.centerY.equalTo(self)
            $0.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc func handleLogout() {
        delegate?.handleLogout()
    }
}
