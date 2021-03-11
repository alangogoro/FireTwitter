//
//  NitificationService.swift
//  FireTwT
//
//  Created by usr on 2021/3/10.
//

import Firebase

struct NotificationService {
    static let shared = NotificationService()
    
    func uploadNotification(type: NotificationType,
                            user: User? = nil,
                            tweet: Tweet? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970),
                                     "uid": uid,
                                     "type": type.rawValue]
        
        // 若通知內含有推特資料
        if let tweet = tweet {
            values["tweetID"] = tweet.tweetID
            
            DB_REF.child("notifications")
                .child(tweet.user.uid)
                .childByAutoId().updateChildValues(values)
        } else if let user = user {
            DB_REF.child("notifications")
                .child(user.uid)
                .childByAutoId().updateChildValues(values)
        }
    }
    
    func fetchNotifications(completion: @escaping ([Notification]) -> Void) {
        var notifications = [Notification]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        DB_REF.child("notifications")
            .child(uid).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value
                as? [String: Any] else { return }
            guard let uid = dictionary["uid"]
                as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let notification = Notification(user: user,
                                                dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }
}
