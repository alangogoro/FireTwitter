//
//  ProfileHeaderViewModel.swift
//  FireTwT
//
//  Created by usr on 2021/2/3.
//

enum ProfileFilterOptions: Int, CaseIterable {
    
    case tweets
    case replies
    case likes
    
    var titleOfOption: String {
        switch (self) {
        case .tweets: return "Tweets"
        case .replies: return "Tweets & Replies"
        case .likes: return "Likes"
        }
    }
    
}
