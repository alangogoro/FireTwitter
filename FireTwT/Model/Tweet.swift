//
//  Tweet.swift
//  FireTwT
//
//  Created by usr on 2021/1/25.
//

import Foundation

struct Tweet {
    let tweetID: String
    var user: User
    var timestamp: Date!
    let caption: String
    var likes: Int
    let retweetCount: Int
    // 預設推特沒被按過 ❤️ Like
    var didLike = false
    // 如果是回推，這個 String(Optional) 將有值
    var replyingTo: String?
    var isReply: Bool { return replyingTo != nil }
    
    
    init(tweetID: String, user: User, dictionary: [String: Any]) {
        self.tweetID = tweetID
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            /* ➡️ 把從 Firebase Database 取得的時間戳記（1970 年開始的秒數）
             * 轉換為 Swift 的日期類型以方便使用 */
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let replyingTo = dictionary["replyingTo"] as? String {
            self.replyingTo = replyingTo
        }
    }
}
