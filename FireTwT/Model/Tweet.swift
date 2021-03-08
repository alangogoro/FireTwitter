//
//  Tweet.swift
//  FireTwT
//
//  Created by usr on 2021/1/25.
//

import Foundation

struct Tweet {
    let caption: String
    let tweetID: String
    let uid    : String
    var likes: Int
    let retweetCount: Int
    var timestamp: Date!
    var user: User
    var didLike = false
    
    init(tweetID: String, user: User, dictionary: [String: Any]) {
        self.tweetID = tweetID
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweets"] as? Int ?? 0
        
        if let timestamp = dictionary["timestamp"] as? Double {
            /* ➡️ 把從 Firebase Database 取得的時間戳記（1970 開始的秒數）
             * 轉換為 Swift 的日期類型以方便使用 */
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
    }
}
