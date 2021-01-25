//
//  TweetService.swift
//  FireTwT
//
//  Created by usr on 2021/1/25.
//

import Firebase

struct TweetService {
    
    static let shared = TweetService()
    
    func uploadTweet(caption: String,
                     completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid": uid,/* ⭐️ NSDate().timeIntervalSince1970 以秒顯示的日期格式 ⭐️ */
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String: Any]
        
        /* ⭐️ 在 Firebase Database 的 tweets 位置下 ⭐️
         * 利用自動生成的 ID 建立文件，並且更新文件的內容 */
        DB_REF.child("tweets").childByAutoId()
            .updateChildValues(values,
                               withCompletionBlock: completion)
    }
}
