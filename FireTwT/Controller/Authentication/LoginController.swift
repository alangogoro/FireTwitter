//
//  LoginController.swift
//  FireTwT
//
//  Created by usr on 2021/1/14.
//

import UIKit

class LoginController: UIViewController {
    
    // MARK: - Properties
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "TwitterLogo")  //鍵入 Image Literal，選取圖片
        return iv
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
    
    private let emailTextField: UITextField = {
        let tf = Utilities().customTextField(withPlaceholder: "Email")
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = Utilities().customTextField(withPlaceholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    // MARK: - Selectors
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .twitterBlue
        
        /* 🔰⭐️ 讓最上方的狀態列呈反白色調（白色文字） */
        navigationController?.navigationBar.barStyle = .black
        /* ⭐️ 隱藏 NavigationBar */
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.centerX(inView: view,
                              topAnchor: view.safeAreaLayoutGuide.topAnchor)
        logoImageView.setDimensions(width: 150, height: 150)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,
                                                   passwordContainerView])
        stack.axis = .vertical
        stack.spacing = 8
        
        view.addSubview(stack)
        stack.anchor(top: logoImageView.bottomAnchor,
                     left: view.leftAnchor, right: view.rightAnchor,
                     paddingLeft: 16, paddingRight: 16)
    }
}
