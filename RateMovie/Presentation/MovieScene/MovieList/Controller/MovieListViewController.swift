//
//  MovieListViewController.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import UIKit
import Kingfisher

class MovieListViewController: UIViewController, RedNavBar {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: DefaultCollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    var viewModel: MovieListViewModel?
}

extension MovieListViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
        }
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBackground()
        viewModel?.getMovieNowPlaying()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        configureCollectionView()
        verticalCollectionConfigure()
        bind()
        setupView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewHeight.constant = UIScreen.main.bounds.height
        
        let recommendationHeight = collectionView.collectionViewLayout.collectionView?.contentSize.height
        collectionViewHeight.constant = recommendationHeight ?? 0
        self.view.layoutIfNeeded()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetNavigationBackground()
    }
}

extension MovieListViewController {
    private func setupTheme() {
        view.backgroundColor = RMColor.backgroundPrimary
        scrollView.backgroundColor = RMColor.backgroundPrimary
        collectionView.backgroundColor = .clear
    }
    
    private func setupView () {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Movie"
    }
    private func verticalCollectionConfigure() {
        collectionView.isBouncesVertical = true
    }
    
    private func updateCollectionViewHeights() {
        self.collectionViewHeight.constant = self.collectionView.layoutContentSizeHeight
        self.view.layoutIfNeeded()
    }
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            MovieItemCollectionViewCell.nib(),
            forCellWithReuseIdentifier: MovieItemCollectionViewCell.identifier
        )
    }
    
    private func bind() {
        viewModel?.movieList.observe(on: self) { [weak self] moviee in
            guard let self = self else { return }
            self.collectionView.reloadData()
            self.updateCollectionViewHeights()
        }
    }
}
