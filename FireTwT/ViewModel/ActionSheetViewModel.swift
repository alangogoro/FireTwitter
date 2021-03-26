//
//  ActionSheetViewModel.swift
//  FireTwT
//
//  Created by usr on 2021/3/4.
//

import Foundation

struct ActionSheetViewModel {
    private let user: User
    
    var options: [ActionSheetOption] {
        var results = [ActionSheetOption]()
        
        // 若是本人，增加一個 可以自刪推文 的選項
        if user.isCurrentUser {
            results.append(.delete)
        } else {
            // 根據追蹤狀況，顯示 不再追蹤|開始追蹤 的選項
            let followOption: ActionSheetOption =
                user.isFollowed ? .unfollow(user) : .follow(user)
            results.append(followOption)
        }
        results.append(.report)
        return results
    }
    
    
    init(user: User) {
        self.user = user
    }
}

enum ActionSheetOption {
    case follow(User)
    case unfollow(User)
    case report
    case delete
    
    /// ActionSheet 行為表單 **選項的標題**
    var description: String {
        switch self {
        case .follow(let user): return "Follow @\(user.username)"
        case .unfollow(let user): return "Unfollow @\(user.username)"
        case .report: return "Report Tweet"
        case .delete: return "Delete Tweet"
        }
    }
}
