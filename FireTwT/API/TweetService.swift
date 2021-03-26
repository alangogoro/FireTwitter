//
//  TweetService.swift
//  FireTwT
//
//  Created by usr on 2021/1/25.
//

import Firebase

struct TweetService {
    
    static let shared = TweetService()
    
    /** 上傳推特 */
    func uploadTweet(caption: String,
                     type: UploadTweetConfiguration, 
                     completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values = ["uid": uid,/* ⭐️ NSDate().timeIntervalSince1970 以秒顯示的日期格式 ⭐️ */
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String: Any]
        
        switch type {
        case .tweet:
            /* ⭐️ 在 Firebase Database 的 tweets 位置下 ⭐️
             * 利用自動生成的 ID 建立文件，並且更新文件的內容 */
            DB_REF.child("tweets")
                .childByAutoId().updateChildValues(values) { (err, ref) in
                
                /* ➡️ 完成後，也在 user-tweets 位置下 uid 的文件中
                 * 記入 [TweetID: 1] 的資料（帳號推特歷史）*/
                guard let tweetID = ref.key else { return }
                DB_REF.child("user-tweets")
                    .child(uid)
                    .updateChildValues([tweetID: 1],
                                       withCompletionBlock: completion)
            }
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username
            
            // ➡️ 更新特定推特的回推資料
            DB_REF.child("tweet-replies")
                .child(tweet.tweetID).childByAutoId()
                .updateChildValues(values) { (err, ref) in
                // ➡️ 更新帳號曾經回推過的列表
                guard let replyKey = ref.key else { return }
                DB_REF.child("user-replies")
                    .child(uid).updateChildValues([tweet.tweetID: replyKey],
                                                  withCompletionBlock: completion)
            }
        }
    }
    
    /// 查詢特定 推特ID 其推特的內容
    func fetchTweet(withTweetID tweetID: String,
                    completion: @escaping (Tweet) -> ()) {
        DB_REF.child("tweets")
            .child(tweetID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value
                    as? [String: Any] else { return }
            guard let uid = dictionary["uid"]
                    as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(tweetID: tweetID,
                                  user: user,
                                  dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    
    /// 查詢特定使用者的推文
    func fetchTweets(forUser user: User,
                     completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        DB_REF.child("user-tweets")
            .child(user.uid).observe(.childAdded) { snapshot in
            // ➡️ 取得 推文的ID
            let tweetID = snapshot.key
            
            // ➡️ 從 推文ID 抓取推特的內容
            self.fetchTweet(withTweetID: tweetID) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    /**
     * 查詢所有推文
     * - Parameter completion: 追蹤中帳號，以及自己帳號的 **[Tweet]**
     */
    func fetchTweets(completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        DB_REF.child("user-following") // ➡️ 查詢 追蹤中的帳號
            .child(currentUid).observe(.childAdded) { snapshot in
            let followingUid = snapshot.key
            
            DB_REF.child("user-tweets") // ➡️ 查詢追蹤帳號的 推文ID
                .child(followingUid).observe(.childAdded) { snapshot in
                let tweetID = snapshot.key
                
                self.fetchTweet(withTweetID: tweetID) { tweet in // ➡️ 依照 推文ID 查詢其內容
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
        DB_REF.child("user-tweets") // ➡️ 查詢自己的 推文ID
            .child(currentUid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { tweet in     // ➡️ 依照 推文ID 查詢其內容
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    /// 查詢特定 推特ID 的回推
    func fetchReplies(forTweet tweet: Tweet,
                      completion: @escaping ([Tweet]) -> ()) {
        var replies = [Tweet]()
        
        DB_REF.child("tweet-replies")
            .child(tweet.tweetID)
            .observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            guard let dictionary = snapshot.value
                    as? [String: Any] else { return }
            guard let uid = dictionary["uid"]
                    as? String else { return }
            
            // ➡️ 查詢每則回推的帳號資料
            UserService.shared.fetchUser(uid: uid) { user in
                let reply = Tweet(tweetID: tweetID,
                                  user: user,
                                  dictionary: dictionary)
                replies.append(reply)
                completion(replies)
            }
        }
    }
    
    /// 查詢帳號曾回推過的推特
    func fetchReplies(forUser user: User,
                      completion: @escaping ([Tweet]) -> ()) {
        var replies = [Tweet]()
        
        DB_REF.child("user-replies") // ➡️ 查詢 uid 下的所有回推ID
            .child(user.uid).observe(.childAdded) { snapshot in
            /* "user-replies" 表資料如下
             * [<Key>: <Value>]
             * [推特ID: "來自這個帳號的 回推的ID"] */
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value
                as? String else { return }
            
            DB_REF.child("tweet-replies") // ➡️ 查詢 回推的內容
                .child(tweetKey).child(replyKey)
                .observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value
                    as? [String: Any] else { return }
                guard let uid = dictionary["uid"]
                    as? String else { return }
                let replyID = snapshot.key
                
                // ➡️ 查詢每則回推的帳號資料
                UserService.shared.fetchUser(uid: uid) { user in
                    let reply = Tweet(tweetID: replyID,
                                      user: user,
                                      dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    
    func likeTweet(tweet: Tweet,
                   completion: @escaping (Error?, DatabaseReference) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        // 更新推特文件中的 ❤️ 數
        DB_REF.child("tweets")/* ⭐️ 在 Database 更新欄位 .setValue ⭐️ */
            .child(tweet.tweetID).child("likes").setValue(likes)
        
        let REF_USER_LIKES  = DB_REF.child("user-likes")
        let REF_TWEET_LIKES = DB_REF.child("tweet-likes")
        
        if tweet.didLike { // 移除 ❤️
            REF_USER_LIKES
                .child(uid).child(tweet.tweetID)
                .removeValue { (err, ref) in
                
                REF_TWEET_LIKES
                    .child(tweet.tweetID)
                    .removeValue(completionBlock: completion)
            }
        } else {           // 增加 ❤️
            REF_USER_LIKES
                .child(uid)
                .updateChildValues([tweet.tweetID: 1]) { (err, ref) in
                
                REF_TWEET_LIKES
                    .child(tweet.tweetID)
                    .updateChildValues([uid: 1],
                                       withCompletionBlock: completion)
            }
        }
    }
    
    /**
     * 查詢使用者 ❤️ Liked 的推特 **[Tweet]**
     * - Parameter completion: 回傳的陣列 didLike 皆設為`true`
     */
    func fetchLikedTweet(forUser user: User,
                         completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        
        DB_REF.child("user-likes")
            .child(user.uid).observe(.childAdded) { snapshot in
            // ➡️ 資料內容都存成 [TweetID: 1]，因此 Snapshot 的 Key 即是 推特ID
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { likedTweet in
                var tweet = likedTweet
                tweet.didLike = true
                
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    /// 查詢使用者是否 ❤️ 過特定推特
    func checkIfLikedTweet(_ tweet: Tweet,
                           completion: @escaping (Bool)-> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        DB_REF.child("user-likes")
            .child(uid).child(tweet.tweetID)
            .observeSingleEvent(of: .value) { snapshot in
            // ⭐️ DataSnapshot.exist() 將回傳 Bool ⭐️
            completion(snapshot.exists())
        }
    }
}
