//
//  UploadTweetController.swift
//  FireTwT
//
//  Created by usr on 2021/1/22.
//

import UIKit
import SnapKit

class UploadTweetController: UIViewController {
    
    // MARK: - Properties
    private let user: User
    
    /*    ❗️lazy var❗️
     * 被宣告為 lazy var 的物件不會在 viewDidLoad⋯ 情況生成
     * 只有當被呼叫時，才會執行建構式。 */
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        // ➡️ 設置 Button 的標題樣式
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        // ⭐️ 設置 Button 成圓角樣式 ⭐️
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        
        button.addTarget(self,
                         action: #selector(handleUploadTweet),
                         for: .touchUpInside)
        
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48 / 2
        
        iv.backgroundColor = .systemTeal
        return iv
    }()
    
    private let captionTextView = CaptionTextView()
    
    // MARK: - Lifecycle
    /* ⭐️ 自定義建構式，需傳入 User 物件才能生成頁面 ⭐️ */
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc func handleUploadTweet() {
        guard let caption = captionTextView.text else { return }
        
        TweetService.shared.uploadTweet(caption: caption) { (error, ref) in
            if let error = error {
                print("===== ⛔️ DEBUG: Failed to Upload tweet with error \(error.localizedDescription)")
                return
            }
            print("===== ✅ DEBUG: Upload tweet successful")
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - API
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        
        let stack = UIStackView(arrangedSubviews: [profileImageView,
                                                   captionTextView])
        stack.axis = .horizontal
        stack.spacing = 12
        
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
    }
    
    func configureNavigationBar() {
        // ➡️ 設定 NavigationBar 成白色、不透明
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .cancel,
                            target: self,
                            action: #selector(handleCancel))
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(customView: actionButton)
    }
}