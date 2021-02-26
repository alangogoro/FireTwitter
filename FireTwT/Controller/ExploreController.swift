//
//  ExplorerController.swift
//  FireTwT
//
//  Created by usr on 2021/1/13.
//

import UIKit

private let reuseIdentifier = "UserCell"

class ExploreController: UITableViewController {
    
    // MARK: - Properties
    private var users = [User]() {
        didSet { tableView.reloadData() }
    }
    
    /* ⭐️ 宣告 SearchController ⭐️ */
    private let searchController = UISearchController(searchResultsController: nil)
    // ➡️ 承接搜尋結果的陣列
    private var filterdUsers = [User]() {
        didSet { tableView.reloadData() }
    }
    // ➡️ 用於判斷是否處於搜尋狀態的 Bool
    private var inSearchMode: Bool {
        return searchController.isActive &&
            !searchController.searchBar.text!.isEmpty
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureSearchController()
        fetchUsers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ➡️ 確保可以呈現 NavigationBar
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - API
    func fetchUsers() {
        UserService.shared.fetchUsers { users in
            self.users = users
        }
    }
    
    // MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        /* ⭐️ 為 NavigationItem 加上 Title ⭐️ */
        navigationItem.title = "Explore"
        
        tableView.register(UserCell.self,
                           forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}


// MARK: - TableViewDataSource/Delegate
extension ExploreController {
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filterdUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                 for: indexPath) as! UserCell
        
        let user = inSearchMode ? filterdUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filterdUsers[indexPath.row] : users[indexPath.row]
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ExploreController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText =
                searchController.searchBar.text?.lowercased() else { return }
        
        /*               ⭐️ .filter({ 條件 }) ⭐️ */
        filterdUsers = users.filter({ $0.username.contains(searchText) ||
                                        $0.fullname.contains(searchText) })
    }
}
