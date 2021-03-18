//
//  EditProfileController.swift
//  FireTwT
//
//  Created by usr on 2021/3/18.
//

import UIKit

class EditProfileController: UITableViewController {
    
    // MARK: - Properties
    private let user: User
    
    private lazy var headerView = EditProfileHeader(user: user)
    
    // MARK: - Liftcycle
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
    }
    
    // MARK: - Selectors
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        
    }
    
    // MARK: - API
    
    // MARK: - Helpers
    func configureNavigationBar() {
        navigationController?.navigationBar.barTintColor = .twitterBlue
        // ➡️ 設定 NavigationBar 上的文字為白色
        navigationController?.navigationBar.barStyle = .black
        // ➡️ 設定 NavigationBar 是否呈半透明
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        
        // ⭐️ 設定 NavigationBar 標題
        navigationItem.title = "Edit Profile"
        
        // ➡️ 設定 NavigationBar 左右側的按鈕
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0,
                                  width: view.frame.width, height: 180)
        headerView.delegate = self
        
        tableView.tableFooterView = UIView()
    }
}


extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        print("======= 🔘 DEBUG: Handle change photo..")
    }
}
