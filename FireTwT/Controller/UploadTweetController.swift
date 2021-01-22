//
//  UploadTweetController.swift
//  FireTwT
//
//  Created by usr on 2021/1/22.
//

import UIKit

class UploadTweetController: UIViewController {
    
    // MARK: - Properties
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Selectors
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc func handleUploadTweet() {
        print("===== ☑️ DEBUG: Upload tweet")
    }
    
    // MARK: - API
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .twitterBlue
        
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
