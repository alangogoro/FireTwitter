//
//  ActionSheetLauncher.swift
//  FireTwT
//
//  Created by usr on 2021/2/26.
//

import Foundation
import UIKit

private let reuseIdentifier = "ActionSheetCell"

protocol ActionSheetLauncherDelegate: class {
    func didSelect(option: ActionSheetOption)
}

                     /* ⭐️ NSObject ⭐️ */
class ActionSheetLauncher: NSObject {
    
    // MARK: - Properties
    private let user: User
    private let tableView = UITableView()
    private lazy var viewModel = ActionSheetViewModel(user: user)
    weak var delegate: ActionSheetLauncherDelegate?
    private var tableViewHeight: CGFloat?
    
    /* ⭐️ 以此存取 App 正在使用的 window ⭐️ */
    private var window: UIWindow?
    // 覆蓋 ActionSheet 之外其它畫面的灰色半透明 view
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        //   ❗️⚠️ UITapGestureRecognizer ⚠️❗️ 不要誤植成 UIGestureRecognizer（會毫無反應）
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(handleDismissal))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var footerView: UIView = {
        let view = UIView()
        
        view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancelButton.anchor(left: view.leftAnchor, right: view.rightAnchor,
                            paddingLeft: 12, paddingRight: 12)
        cancelButton.centerY(inView: view)
        cancelButton.layer.cornerRadius = 50 / 2
        
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGroupedBackground
        
        button.addTarget(self,
                         action: #selector(handleDismissal),
                         for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init()
        
        configureTableView()
    }
    
    // MARK: - Helpers
    func show() {
        /* ⭐️🔰 獲得 App 使用的 window 🔰⭐️
         * 並在其上加入 TableView 視圖 */
        guard let window =
                UIApplication.shared
                .windows.first(where: { $0.isKeyWindow })
        else { return }
        self.window = window
        
        window.addSubview(dimView)
        dimView.frame = window.frame
        
        // 在 UIWindow 上加入視圖，才能確保覆蓋一整個 App 畫面
        window.addSubview(tableView)
        let height = CGFloat(viewModel.options.count * 60) + 100
        tableView.frame = CGRect(x: 0, y: window.frame.height,
                                 width: window.frame.width,
                                 height: height)
        self.tableViewHeight = height
        
        /* ⭐️ 動畫呈現 ActionSheet ⭐️ */
        UIView.animate(withDuration: 0.5) {
            self.dimView.alpha = 1
            self.showTableView(true)
        }
    }
    
    func showTableView(_ shouldShow: Bool) {
        guard let window = window else { return }
        guard let height = tableViewHeight else { return }
        
        let y = shouldShow ? window.frame.height - height : window.frame.height
        tableView.frame.origin.y = y
    }
    
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false // ➡️ 不能捲動
        
        tableView.register(ActionSheetCell.self,
                           forCellReuseIdentifier: reuseIdentifier)
    }
    
    // MARK: - Selectors
    @objc func handleDismissal() {
        UIView.animate(withDuration: 0.5) {
            self.dimView.alpha = 0
            self.tableView.frame.origin.y += 300
        }
    }
}

// MARK: - UITableView
extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int)
    -> Int {
        return viewModel.options.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(withIdentifier: reuseIdentifier,
                                 for: indexPath) as! ActionSheetCell
        cell.option = viewModel.options[indexPath.row]
        return cell
    }
}

extension ActionSheetLauncher: UITableViewDelegate {
    /* ⭐️ 自訂 TableView Footer ⭐️ */
    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int)
    -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int)
    -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]
        
        // ➡️ ActionSheet 動畫結束後依照所選項目呼叫代理
        UIView.animate(withDuration: 0.5) {
            self.dimView.alpha = 0
            self.showTableView(false)
        } completion: { _ in
            self.delegate?.didSelect(option: option)
        }
        
    }
}
