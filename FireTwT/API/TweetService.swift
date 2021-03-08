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
        
        let values = ["uid": uid,/* ⭐️ NSDate().timeIntervalSince1970 以秒顯示的日期格式 ⭐️ */
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
            
            DB_REF.child("tweet-replies")
                .child(tweet.tweetID).childByAutoId()
                .updateChildValues(values, withCompletionBlock: completion)
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
    
    func fetchTweets(forUser user: User,
                     completion: @escaping ([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        DB_REF.child("user-tweets").child(user.uid)
            .observe(.childAdded) { snapshot in
            // ➡️ 取得 Tweet 的 ID
            let tweetID = snapshot.key
            
            // ➡️ 從 Tweet ID 抓取推特的文章內容
            DB_REF.child("tweets").child(tweetID)
                .observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value
                    as? [String: Any] else { return }
                guard let uid = dictionary["uid"]
                    as? String else { return }
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let tweet = Tweet(tweetID: tweetID,
                                      user: user,
                                      dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
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
}
