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
    }
}
