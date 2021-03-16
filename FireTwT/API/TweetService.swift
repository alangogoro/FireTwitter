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
            let ref = DB_REF.child("tweets").childByAutoId()
            ref.updateChildValues(values) { (err, ref) in
                
                /* ➡️ 完成後，也在 user-tweets 位置下 uid 的文件中
                 * 記入 [tweetID: 1] 的資料 */
                guard let tweetID = ref.key else { return }
                DB_REF.child("user-tweets").child(uid)
                    .updateChildValues([tweetID: 1],
                                       withCompletionBlock: completion)
            }
            
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.username
            
            // ➡️ 更新特定 Tweet 回推的資料
            DB_REF.child("tweet-replies")
                .child(tweet.tweetID).childByAutoId()
                .updateChildValues(values) { (err, ref) in
                    // ➡️ 更新使用者曾經回推的資料
                guard let replyKey = ref.key else { return }
                DB_REF.child("user-replies")
                    .child(uid).updateChildValues([tweet.tweetID: replyKey],
                                                  withCompletionBlock: completion)
            }
        }
    }
    
    func fetchTweets(completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        DB_REF.child("tweets")
            .observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(tweetID: tweetID, user: user, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    /// 由 TweetID 抓取特定推特的內容
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
    
    func fetchTweets(forUser user: User,
                     completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        DB_REF.child("user-tweets").child(user.uid)
            .observe(.childAdded) { snapshot in
            // ➡️ 取得 Tweet 的 ID
            let tweetID = snapshot.key
            
            // ➡️ 從 Tweet ID 抓取推特的文章內容
            self.fetchTweet(withTweetID: tweetID) { tweet in
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    
    /// 查詢 Tweet 回推
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
            
            // 查詢回推的帳號資料
            UserService.shared.fetchUser(uid: uid) { user in
                let reply = Tweet(tweetID: tweetID,
                                  user: user,
                                  dictionary: dictionary)
                replies.append(reply)
                completion(replies)
            }
            
        }
    }
    
    /// 查詢帳號曾經回推的推文
    func fetchReplies(forUser user: User,
                      completion: @escaping ([Tweet]) -> ()) {
        /* 🚧 ========== 待完整解釋程式區塊 ========== 🚧 */
        var replies = [Tweet]()
        
        DB_REF.child("user-replies") // 查詢 uid 下的所有回推
            .child(user.uid).observe(.childAdded) { snapshot in
            
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value
                as? String else { return }
            
            DB_REF.child("tweet-replies") // 查詢 回推內容?
                .child(tweetKey).child(replyKey)
                .observeSingleEvent(of: .value) { snapshot in
                
                guard let dictionary = snapshot.value
                    as? [String: Any] else { return }
                guard let uid = dictionary["uid"]
                    as? String else { return }
                let replyID = snapshot.key
                
                UserService.shared
                    .fetchUser(uid: uid) { user in
                    let reply = Tweet(tweetID: replyID,
                                      user: user,
                                      dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
        /* 🚧 ========== 待完整解釋程式區塊 ========== 🚧 */
    }
    
    func likeTweet(tweet: Tweet,
                   completion: @escaping (Error?, DatabaseReference) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        
        // 更新 ❤️ 數
        DB_REF.child("tweets")
            .child(tweet.tweetID).child("likes").setValue(likes)
        
        let REF_USER_LIKES = DB_REF.child("user-likes")
        let REF_TWEET_LIKES = DB_REF.child("tweet-likes")
        
        if tweet.didLike {
            REF_USER_LIKES
                .child(uid).child(tweet.tweetID)
                .removeValue { (err, ref) in
                REF_TWEET_LIKES
                    .child(tweet.tweetID)
                    .removeValue(completionBlock: completion)
            }
        } else {
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
    
    /// 檢查使用者是否 ❤️ 過指定推文
    func checkIfLikedTweet(_ tweet: Tweet,
                           completion: @escaping (Bool)-> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        DB_REF.child("user-likes")
            .child(uid).child(tweet.tweetID)
            .observeSingleEvent(of: .value) { snapshot in
            // ⭐️ DataSnapshot.exist() returns a Bool ⭐️
            completion(snapshot.exists())
            
        }
    }
    
    func fetchLikedTweet(forUser user: User,
                         completion: @escaping ([Tweet]) -> ()) {
        var tweets = [Tweet]()
        
        DB_REF.child("user-likes")
            .child(user.uid).observe(.childAdded) { snapshot in
            // ➡️ 資料內容都存成 {TweetID: 1}，因此取得 Snapshot 的 Key 即可
            let tweetID = snapshot.key
            
            self.fetchTweet(withTweetID: tweetID) { likedTweet in
                var tweet = likedTweet
                tweet.didLike = true
                
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
}
