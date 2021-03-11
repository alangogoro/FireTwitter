//
//  Notification.swift
//  FireTwT
//
//  Created by usr on 2021/3/8.
//

import Foundation

enum NotificationType: Int {
    case follow
    case like
    case reply
    case retweet
    case mention
}

struct Notification {
    var tweetID: String?
    var timestamp: Date!
    var user: User
    var tweet: Tweet?
    var type: NotificationType!
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        
        if let tweetID = dictionary["tweetID"] as? String {
            self.tweetID = tweetID
        }
        
        /* ⭐️ 將 Firebase 的時間戳記轉換為 Swift 的 Date ⭐️ */
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }
}
