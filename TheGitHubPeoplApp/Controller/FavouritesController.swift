//
//  FavouritesController.swift
//  TheGitHubPeoplApp
//
//  Created by Richard Price on 16/09/2020.
//  Copyright © 2020 twisted echo. All rights reserved.
//

import UIKit

class FavouritesController: UIViewController, FollowerListControllerDelegate {

    let tableView = UITableView()
    var favorites: [Follower] = []
    var followers: [Follower] = []
    weak var delegate: FollowerListControllerDelegate!
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    func makeNetworkCall(username: String, page: Int) {
       showLoadingView()
       NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
           guard let self = self else {return}
           DispatchQueue.main.async {
               self.dismissLoadingView()
           }
           switch result {
           case .success(let followers):
            self.followers.append(contentsOf: followers)
               if self.followers.isEmpty {
                   let message = "This user doesnt have any followers as yet 😀"
                   DispatchQueue.main.sync {
                       self.showEmptyStateView(message: message, in: self.view)
                       return
                   }
               }
                case .failure(let error):
               self.presentRPAlertOnMainThread(title: RPError.GHAlertMessageWrong.rawValue, message: error.rawValue, buttonTitle: RPError.GHOKText.rawValue)
           }
       }
   }


    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    func configureTableView() {
        view.addSubview(tableView)
        
        tableView.frame  = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CustomFavouriteCell.self, forCellReuseIdentifier: CustomFavouriteCell.reuseIdentifier)
    }

    func getFavorites() {
        PersistanceManager.retrieveFavourites { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let favorites):
                if favorites.isEmpty {
                    self.showEmptyStateView(message: "No Favorites?\nAdd one on the follower screen.", in: self.view)
                } else  {
                    self.favorites = favorites
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.view.bringSubviewToFront(self.tableView)
                    }
                }
                
            case .failure(let error):
                self.presentRPAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
    
    func didTapGetFollowers(username: String) {
        print("dispaly message \(username)")
        presentRPAlertOnMainThread(title: RPError.GHAlertUnableTo.rawValue, message: "you already have the followers for \(username) 😥", buttonTitle: RPError.GHOKText.rawValue)
    }
}

