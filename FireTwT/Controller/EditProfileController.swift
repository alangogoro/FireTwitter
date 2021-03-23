//
//  EditProfileController.swift
//  FireTwT
//
//  Created by usr on 2021/3/18.
//

import UIKit


private let reuseIdentifier = "EditProfileCell"

protocol EditProfileControllerDelegate: class {
    func controller(_ controller: EditProfileController,
                    wantsToUpdate user: User)
    func handleLogout()
}

class EditProfileController: UITableViewController {
    
    // MARK: - Properties
    private var user: User
    private var userInfoChanged = false
    weak var delegate: EditProfileControllerDelegate?
    
    private lazy var headerView = EditProfileHeader(user: user)
    private let footerView = EditProfileFooter()
    
    /* 🔰 ImagePickerController 🔰 */
    private let imagePicker = UIImagePickerController()
    private var selectedImage: UIImage? {
        didSet{ headerView.profileImageView.image = selectedImage }
    }
    private var imageChanged: Bool {
        return selectedImage != nil
    }
    
    
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
        
        configureImagePicker()
    }
    
    
    // MARK: - Selectors
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        // 收起鍵盤
        view.endEditing(true)
        
        guard imageChanged || userInfoChanged else { return }
        
        updateUserData()
    }
    
    // MARK: - API
    func updateUserData() {
        if imageChanged && !userInfoChanged {
            print("===== ✅ DEBUG: Changed image and not data")
            updateprofileImage()
        }
        
        if userInfoChanged && !imageChanged {
            UserService.shared.saveUserData(user: user) { (err, ref) in
                print("===== ✅ DEBUG: Changed data and not image")
                self.delegate?.controller(self, wantsToUpdate: self.user)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        if userInfoChanged && imageChanged {
            print("===== ✅ DEBUG: Changed image and data")
            UserService.shared.saveUserData(user: user) { (err, ref) in
                self.updateprofileImage()
            }
        }
    }
    
    func updateprofileImage() {
        guard let image = selectedImage else { return }
        
        UserService.shared.updateProfileImage(image: image) { profileImageUrl in
            self.user.profileImageUrl = profileImageUrl
            self.delegate?.controller(self, wantsToUpdate: self.user)
        }
    }
    
    
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
    }
    
    func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0,
                                  width: view.frame.width, height: 180)
        headerView.delegate = self
        
        tableView.register(EditProfileCell.self,
                           forCellReuseIdentifier: reuseIdentifier)
        
        tableView.tableFooterView = footerView
        footerView.frame = CGRect(x: 0, y: 0,
                                  width: view.frame.width, height: 100)
        footerView.delegate = self
    }
    
    func configureImagePicker() {
        /* 🔰⭐️ 初始化 ImagePickerConrtroller ⭐️🔰 */
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
}


// MARK: - TableView DataSource
extension EditProfileController {
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int)
    -> Int {
        return EditProfileOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                 for: indexPath) as! EditProfileCell
        
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return cell }
        cell.viewModel = EditProfileViewModel(user: user, option: option)
        cell.delegate = self
        
        return cell
    }
}

// MARK: - TableView Delegate
extension EditProfileController {
    override func tableView(_ tableView: UITableView,
                            heightForRowAt indexPath: IndexPath)
    -> CGFloat {
        
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0 }
        // 針對 Bio 欄位，高設為 100
        return option == .bio ? 100 : 48
        
    }
}

// MARK: - EditProfileHeaderDelegate
extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - ImagePickerControllerDelegate
extension EditProfileController: UIImagePickerControllerDelegate,
                                 UINavigationControllerDelegate {
    
    /* 🔰 取得 ImagePickerController 相片 🔰 */
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        self.selectedImage = image
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - EditProfileCellDelegate
extension EditProfileController: EditProfileCellDelegate {
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else { return }
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
        case .fullname:
            guard let fullname = cell.infoTextField.text else { return }
            user.fullname = fullname
        case .username:
            guard let username = cell.infoTextField.text else { return }
            user.username = username
        case .bio:
            user.bio = cell.bioTextView.text
        }
    }
}

// MARK: - EditProfileFooterDelegate
extension EditProfileController: EditProfileFooterDelegate {
    func handleLogout() {
        let alert = UIAlertController(title: nil,
                                      message: "Are you sure to log out?",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log Out",
                                      style: .destructive,
                                      handler: { _ in
                                        print("======= 🔘 DEBUG: Handle log user out..")
                                        self.dismiss(animated: true) {
                                            self.delegate?.handleLogout()
                                        }
                                      }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
