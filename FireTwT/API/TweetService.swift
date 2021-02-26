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
            
            UserService.shared.fetchUser(uid: uid) { user in
                let reply = Tweet(tweetID: tweetID,
                                  user: user,
                                  dictionary: dictionary)
                replies.append(reply)
                completion(replies)
            }
            
        }
    }
}
