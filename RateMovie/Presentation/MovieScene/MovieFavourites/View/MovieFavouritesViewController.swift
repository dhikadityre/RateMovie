//
//  MovieFavouritesViewController.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import UIKit

class MovieFavouritesViewController: UIViewController, RedNavBar {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: MovieFavouritesViewModel?
}

extension MovieFavouritesViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBackground()
        viewModel?.getListFavorite()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favorite"
        configureTableView()
        bind()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetNavigationBackground()
    }
}

extension MovieFavouritesViewController {
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            MovieItemTableViewCell.nib(),
            forCellReuseIdentifier: MovieItemTableViewCell.identifier
        )
    }
    
    private func bind() {
        viewModel?.movieFavouriteList.observe(on: self) { [weak self] movieFavorites in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    internal func triggerOnTapUnfavourite(movieId: Int) {
        DispatchQueue.main.async {
            self.viewModel?.deleteFavorite(with: movieId)
        }
    }
}
