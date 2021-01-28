//
//  TweetViewModel.swift
//  FireTwT
//
//  Created by usr on 2021/1/27.
//
import Foundation
import UIKit

struct TweetViewModel {
    
    let tweet: Tweet
    let user: User
    
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    
    var userInfoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullname,
                                              attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        let subTitle = NSAttributedString(string: " @\(user.username)",
                                          attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                       .foregroundColor: UIColor.lightGray])
        // ➡️ 因為是 NSMutable 字串所以可以 append
        title.append(subTitle)
        
        let stamp = NSAttributedString(string: "．\(timestamp)",
                                       attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                    .foregroundColor: UIColor.lightGray])
        // ➡️ 因為是 NSMutable 字串所以可以 append
        title.append(stamp)
        
        return title
    }
    
    /// Tweet 的發文時間是多久以前
    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timestamp, to: now) ?? "0m"
    }
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.user = tweet.user
    }
}
