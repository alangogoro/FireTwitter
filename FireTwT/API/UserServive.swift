//
//  UserServive.swift
//  FireTwT
//
//  Created by usr on 2021/1/21.
//
import Firebase

struct UserService {
    static let shared = UserService()
    
    func fetchUser(uid: String, completion: @escaping (User) -> Void) {
        
        /* ⭐️ 在 Firebase Database 查詢使用者資料 ⭐️ */
        DB_REF.child("users").child(uid)
            .observeSingleEvent(of: .value) { snapshot in
            
            // FIRDataSnapshot → Dictionary → User
            guard let dictionary = snapshot.value
                    as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            //print("===== ✅ DEBUG: Fetch user \(user.username) data successful")
            completion(user)
        }
    }
    
    func fetchUsers(completion: @escaping ([User]) -> Void) {
        var users = [User]()
        
        DB_REF.child("users").observe(.childAdded) { snapshot in
            let uid = snapshot.key
            guard let dictionary = snapshot.value
                as? [String: Any] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
    
    func followUser(uid: String,
                    completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let FOLLOWING_REF = DB_REF.child("user-following")
        let FOLLOWERS_REF = DB_REF.child("user-followers")
        
        FOLLOWING_REF.child(currentUid)
            .updateChildValues([uid: 1]) { (err, ref) in
            print("===== ☑️ DEBUG: Current uid \(currentUid) started following \(uid)")
            FOLLOWERS_REF.child(uid)
                .updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
    }
    
    func unfollowUser(uid: String,
                      completion: @escaping (Error?, DatabaseReference) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let FOLLOWING_REF = DB_REF.child("user-following")
        let FOLLOWERS_REF = DB_REF.child("user-followers")
        
        /* ⭐️ 從 Realtime Database
         * 刪除 following 與 followers 的兩筆資料 ⭐️ */
        FOLLOWING_REF.child(currentUid)
            .child(uid).removeValue { (err, ref) in
            FOLLOWERS_REF.child(uid)
                .child(currentUid).removeValue(completionBlock: completion)
        }
    }
    
    func checkIfFollowing(uid: String,
                          completion: @escaping (Bool) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        /* ⭐️ 確認查詢的資料是否存在
         * snapshot.exist() ⭐️ */
        DB_REF.child("user-following")
            .child(currentUid)
            .child(uid).observeSingleEvent(of: .value) { snapshot in
                completion(snapshot.exists()) // 回傳 Bool
        }
    }
    
    func fetchUserStates(uid: String, completion: @escaping (UserFollowStats) -> ()) {
        
        let FOLLOWING_REF = DB_REF.child("user-following")
        let FOLLOWERS_REF = DB_REF.child("user-followers")
        
        FOLLOWERS_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
            /* ⭐️ SnapShot.children.allObjects ⭐️ */
            let followers = snapshot.children.allObjects.count
            
            FOLLOWING_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
                let following = snapshot.children.allObjects.count
                
                let stats = UserFollowStats(followers: followers,
                                            following: following)
                completion(stats)
            }
        }
    }
    
    func saveUserData(user: User, completion: @escaping (Error?, DatabaseReference) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["fullname": user.fullname,
                      "username": user.username,
                      "bio": user.bio ?? ""]
        
        DB_REF.child("users")
            .child(uid).updateChildValues(values,
                                          withCompletionBlock: completion)
    }
    
    func updateProfileImage(image: UIImage, completion: @escaping (URL?) -> ()) {
        guard let imageData =
                image.jpegData(compressionQuality: 0.3) else { return }
        guard let uid =
                Auth.auth().currentUser?.uid else { return }
        
        let filename = NSUUID().uuidString
        let ref = STORAGE_REF.child("profile_images").child(filename)
        
        ref.putData(imageData, metadata: nil) { (meta, error) in
            ref.downloadURL { (url, err) in
                guard let profileImageUrl =
                        url?.absoluteString else { return }
                
                let values = ["profileImageUrl": profileImageUrl]
                DB_REF.child("users")
                    .child(uid).updateChildValues(values) { (err, ref) in
                    completion(url)
                }
            }
        }
    }
    
    func fetchUser(withUsername username: String,
                   completion: @escaping (User) -> ()) {
        DB_REF.child("user-usernames")
            .child(username).observeSingleEvent(of: .value) { snapshot in
            // SnapShot: { username: uid }
            guard let uid = snapshot.value as? String else { return }
            self.fetchUser(uid: uid, completion: completion)
        }
    }
}
