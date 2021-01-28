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
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .twitterBlue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
}

