//
//  MovieDetailSimilarView.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import UIKit

class MovieDetailSimilarView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var similarBarView: UIView!
    @IBOutlet weak var similarTitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var onSelectMovie: ((MovieIdSimilarResponse.Result) -> Void)?
    private var movies: [MovieIdSimilarResponse.Result] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        if let loadedView = bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as? UIView {
            loadedView.frame = bounds
            loadedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(loadedView)
            self.view = loadedView
        }
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            MovieItemCollectionViewCell.nib(),
            forCellWithReuseIdentifier: MovieItemCollectionViewCell.identifier
        )
    }
}

extension MovieDetailSimilarView {
    func setView(with viewModel: MovieDetailSimilarViewModel) {
        self.movies = viewModel.movies
        collectionView.reloadData()
        emptyLabel.isHidden = !viewModel.movies.isEmpty
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
extension MovieDetailSimilarView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieItemCollectionViewCell.identifier,
            for: indexPath
        ) as? MovieItemCollectionViewCell,
        indexPath.row < movies.count else {
            return UICollectionViewCell()
        }
        
        let movie = movies[indexPath.row]
        cell.configure(
            title: movie.title ?? movie.originalTitle,
            rating: movie.voteAverage,
            language: movie.originalLanguage,
            posterPath: movie.posterPath,
            isFavorite: false
        )
        cell.favoriteView.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < movies.count else { return }
        let selectedMovie = movies[indexPath.row]
        onSelectMovie?(selectedMovie)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MovieDetailSimilarView: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 125, height: 215)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 14
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16)
    }
}
