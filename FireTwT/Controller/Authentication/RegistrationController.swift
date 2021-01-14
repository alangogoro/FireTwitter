//
//  RegistrationController.swift
//  FireTwT
//
//  Created by usr on 2021/1/14.
//

import UIKit

class RegistrationController: UIViewController {
    
    // MARK: - Properties
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
         
    }
    
    @objc func handleRegistration() {
        
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .twitterBlue
        
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
