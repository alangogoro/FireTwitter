//
//  NitificationService.swift
//  FireTwT
//
//  Created by usr on 2021/3/10.
//

import Firebase

struct NotificationService {
    static let shared = NotificationService()
    
    func uploadNotification(toUser user: User,
                            type: NotificationType,
                            tweetID: String? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970),
                                     "uid": uid,
                                     "type": type.rawValue]
        
        // 若通知內含有推文資料
        if let tweetID = tweetID {
            values["tweetID"] = tweetID
        }
        
        DB_REF.child("notifications")
            .child(user.uid)
            .childByAutoId().updateChildValues(values)
    }
    
    func fetchNotifications(completion: @escaping ([Notification]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        /* ➡️ 檢查使用者有無通知，如果1條也沒有便回傳空陣列
         * 避免呼叫頁面的 RefreshControl 無止盡的轉圈等待結果 */
        DB_REF.child("notifications")
            .child(uid).observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                completion([Notification]())
            } else {
                /* ➡️ 確認使用者有通知資料後，利用 Uid 查詢所有通知 */
                self.getNotifications(byUid: uid, completion: completion)
            }
        }
    }
    fileprivate func getNotifications(byUid uid: String,
                                      completion: @escaping ([Notification]) -> ()) {
        var notifications = [Notification]()
        
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
