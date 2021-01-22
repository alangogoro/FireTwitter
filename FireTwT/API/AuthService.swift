//
//  AuthService.swift
//  FireTwT
//
//  Created by usr on 2021/1/18.
//
import UIKit
import Firebase

struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    
    static let shared = AuthService()
    
    func registerUser(credentials: AuthCredentials,
                      completion: @escaping (Error?, DatabaseReference)-> Void) {
        
        let email = credentials.email
        let password = credentials.password
        let fullname = credentials.fullname
        let username = credentials.username
        
        /* ➡️ 在 Firebase Storage 上傳圖片，並取回該檔案的連結 */
        // 壓縮照片，產生檔案名稱（UUID）
        let image = credentials.profileImage
        guard let imageData = image.jpegData(compressionQuality: 0.3) else { return }
        let filename = UUID().uuidString
        
        // ⭐️ 準備 Firebase Storage 中圖片要存放的位置 ⭐️
        let storageRef = STORAGE_REF.child("profile_images")
            .child(filename)
        
        // ⭐️ 在 Storage 該位置上傳資料 putData ⭐️
        storageRef.putData(imageData, metadata: nil) { (meta, error) in
            // 上傳完畢後再取得檔案的連結
            storageRef.downloadURL { (url, error) in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                /* ➡️ 在 Firebase 註冊，並更新資料庫（新增該帳號的資料） */
                // 利用 Email, 密碼註冊帳號
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    if let error = error {
                        print("===== ⛔️ DEBUG: Error is \(error.localizedDescription)")
                        return
                    }
                    
                    // 準備該帳號的資料欄位、值
                    guard let uid = result?.user.uid else { return }
                    let values = ["email": email,
                                  "username": username,
                                  "fullname": fullname,
                                  "profileImageUrl": profileImageUrl]
                    
                    // ⭐️ 準備 Firebase Database 中資料要存放的位置 ⭐️
                    let dbRef = DB_REF.child("users")
                        .child(uid)
                    /* ⭐️ 在 Database 該位置更新資料 updateChildValues ⭐️
                     * 並且透過傳出 @escaping Callback 函式自訂註冊結束後要執行的程式 */
                    dbRef.updateChildValues(values) { (error, databaseRef) in
                        print("===== ☑️ DEBUG: Successfully updated user information")
                        completion(error, databaseRef)
                    }
                    
                }
            }
        }
        
    }
    
    func logUserIn(withEmail email: String, password: String,
                   completion: @escaping (AuthDataResult?, Error?)-> Void) {
        Auth.auth().signIn(withEmail: email, password: password,
                           completion: completion)
    }
    
}
