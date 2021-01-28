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
            print("===== ✅ DEBUG: Fetch user \(user.username) data successful")
            completion(user)
        }
    }
}
