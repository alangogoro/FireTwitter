//
//  RegistrationController.swift
//  FireTwT
//
//  Created by usr on 2021/1/14.
//

import UIKit
import Firebase

class RegistrationController: UIViewController {
    
    // MARK: - Properties
    private let imagePicker = UIImagePickerController()// ⭐️ 圖片選擇器
    private var profileImage: UIImage?
    
    private let uploadPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "upload_photo"), for: .normal)
        
        button.addTarget(self,
                         action: #selector(handleUploadPhoto),
                         for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView: UIView = { //鍵入 Image Literal，選取圖片
        let view = Utilities().customInputContainer(withImage: #imageLiteral(resourceName: "ic_mail_outline_2x"),
                                                    textField: emailTextField)
        return view
    }()
    
    private lazy var passwordContainerView: UIView = { //鍵入 Image Literal，選取圖片
        let view = Utilities().customInputContainer(withImage: #imageLiteral(resourceName: "ic_lock_outline_white_2x"),
                                                    textField: passwordTextField)
        return view
    }()
    
    private lazy var fullnameContainerView: UIView = { //鍵入 Image Literal，選取圖片
        let view = Utilities().customInputContainer(withImage: #imageLiteral(resourceName: "ic_person_outline_white_2x"),
                                                    textField: fullnameTextField)
        return view
    }()
    
    private lazy var usernameContainerView: UIView = { //鍵入 Image Literal，選取圖片
        let view = Utilities().customInputContainer(withImage: #imageLiteral(resourceName: "ic_person_outline_white_2x"),
                                                    textField: usernameTextField)
        return view
    }()
    
    private let emailTextField: UITextField = {
        let tf = Utilities().customTextField(withPlaceholder: "Email")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().customTextField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let fullnameTextField: UITextField = {
        let tf = Utilities().customTextField(withPlaceholder: "Full Name")
        return tf
    }()
    
    private let usernameTextField: UITextField = {
        let tf = Utilities().customTextField(withPlaceholder: "Username")
        return tf
    }()
    
    private let registrationButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        button.backgroundColor = .white
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 5
        
        button.addTarget(self,
                         action: #selector(handleRegistration),
                         for: .touchUpInside)
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = Utilities().attributedButton("Already have an account?",
                                                  " Log In")
        button.addTarget(self,
                         action: #selector(handleShowLogin),
                         for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    
    // MARK: - Selectors
    @objc func handleUploadPhoto() {
         present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleRegistration() {
        guard let profileImage = profileImage else {
            print("===== ⚠️ DEBUG: Do not found profile image")
            return
        }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullname = fullnameTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        
        let credentials = AuthCredentials(email: email,
                                          password: password,
                                          fullname: fullname,
                                          username: username,
                                          profileImage: profileImage)
        AuthService.shared.registerUser(credentials: credentials) { (error, ref) in
            print("===== ✅ DEBUG: Sign up successful")
            
            /* ⭐️ 利用 windows.first(where:) 指定主頁更新 UI，接著返回主頁 ⭐️ */
            guard let window =
                    UIApplication.shared.windows
                    .first(where: { $0.isKeyWindow }) else { return }
            guard let tab = window.rootViewController
                    as? MainTabController else { return }
            tab.authenticateUserAndConfigureUI()
            
            self.dismiss(animated: true)
        }
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .twitterBlue
        
        /* ========== ⭐️ 初始化 ImagePickerController ⭐️ ========== */
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        view.addSubview(uploadPhotoButton)
        uploadPhotoButton.centerX(inView: view,
                                  topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        uploadPhotoButton.setDimensions(width: 128, height: 128)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView,
                                                   fullnameContainerView,
                                                   usernameContainerView,
                                                   registrationButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: uploadPhotoButton.bottomAnchor,
                     left: view.leftAnchor, right: view.rightAnchor,
                     paddingTop: 32,
                     paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(left: view.leftAnchor,
                                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                        right: view.rightAnchor,
                                        paddingLeft: 40,
                                        paddingRight: 40)
    }
}

/* ========== ⭐️ 使用 ImagePickerController，需要同時遵從以下2種協定 ⭐️ ========== */
extension RegistrationController: UIImagePickerControllerDelegate,
                                  UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        /* ⭐️ .editedImage：使用者縮放、剪裁過後的圖片 */
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = profileImage
        
        /* ❗️⭐️ 在設置 UIButton 的圖片時，有分成單一色或原始色的按鈕圖片。
         * 因此要先使用 withRenderingMode 調整該圖片 ⭐️❗️ */
        let image = profileImage.withRenderingMode(.alwaysOriginal)
        self.uploadPhotoButton.setImage(image, for: .normal)
        
        /* ⭐️ 設定 Button 圖片為圓形、維持圖片比例、裁切超過邊界的圖片、加上白色圓框 ⭐️ */
        uploadPhotoButton.imageView?.contentMode = .scaleAspectFill
        uploadPhotoButton.imageView?.clipsToBounds = true
        uploadPhotoButton.layer.cornerRadius = 128 / 2
        uploadPhotoButton.layer.borderColor = UIColor.white.cgColor
        uploadPhotoButton.layer.borderWidth = 3
        uploadPhotoButton.layer.masksToBounds = true
        
        // 關閉 ImagePickerController
        dismiss(animated: true)
    }
    
}
