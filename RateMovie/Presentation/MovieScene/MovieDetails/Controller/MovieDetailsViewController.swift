//
//  MovieDetailsViewController.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 07/10/22.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets (Modular Custom Views)
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navBarView: MovieDetailNavBarView!
    @IBOutlet weak var headerView: MovieDetailHeaderView!
    @IBOutlet weak var infoView: MovieDetailInfoView!
    @IBOutlet weak var genresView: MovieDetailGenresView!
    @IBOutlet weak var storylineView: MovieDetailStorylineView!
    @IBOutlet weak var similarView: MovieDetailSimilarView!
    
    // MARK: - ViewModel
    var viewModel: MovieDetailsViewModel?
    
    // MARK: - Appearance Properties
    private let darkBackground = UIColor(red: 16/255, green: 17/255, blue: 21/255, alpha: 1.0)
}

// MARK: - Lifecycle
extension MovieDetailsViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCallbacks()
        bind()
        viewModel?.didLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - UI & Callbacks Setup
extension MovieDetailsViewController {
    private func setupUI() {
        view.backgroundColor = darkBackground
        scrollView.delegate = self
        updateComponents()
    }
    
    private func setupCallbacks() {
        navBarView.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        navBarView.onShareTapped = { [weak self] in
            self?.handleShare()
        }
        
        navBarView.onFavoriteTapped = { [weak self] in
            self?.viewModel?.toggleFavorite()
        }
        
        storylineView.onToggleExpand = { [weak self] in
            UIView.animate(withDuration: 0.25) {
                self?.view.layoutIfNeeded()
            }
        }
        
        similarView.onSelectMovie = { [weak self] movie in
            self?.navigateToDetail(for: movie)
        }
    }
    
    private func bind() {
        // Observe Full Movie Details
        viewModel?.movieDetail.observe(on: self) { [weak self] _ in
            self?.updateComponents()
        }
        
        // Observe Similar Movies
        viewModel?.movieSimilar.observe(on: self) { [weak self] similar in
            self?.similarView.setView(with: MovieDetailSimilarViewModel(movies: similar))
        }
        
        // Observe Favorite Status
        viewModel?.isFavorite.observe(on: self) { [weak self] isFav in
            self?.navBarView.updateFavorite(isFavorite: isFav, animated: true)
        }
    }
    
    private func updateComponents() {
        guard let vm = viewModel else { return }
        
        headerView.setView(with: MovieDetailHeaderViewModel(backdropURL: vm.backdropURL))
        navBarView.setView(with: MovieDetailNavBarViewModel(title: vm.title, isFavorite: vm.isFavorite.value))
        
        infoView.setView(
            with: MovieDetailInfoViewModel(
                posterURL: vm.posterURL,
                title: vm.title,
                tagline: vm.taglineFormatted,
                rating: vm.ratingFormatted,
                voteCount: vm.voteCountFormatted,
                releaseYear: vm.releaseYearFormatted,
                runtime: vm.runtimeFormatted,
                language: vm.languageFormatted
            )
        )
        
        genresView.setView(with: MovieDetailGenresViewModel(genres: vm.genresFormatted))
        storylineView.setView(with: MovieDetailStorylineViewModel(overview: vm.overview))
    }
}

// MARK: - Navigation & Action Handlers
extension MovieDetailsViewController {
    private func handleShare() {
        guard let vm = viewModel else { return }
        let shareText = "Check out \(vm.title) (Rating: ★ \(vm.ratingFormatted)) on RateMovie!\n\n\(vm.overview)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = navBarView.shareButton
        present(activityVC, animated: true)
    }
    
    private func navigateToDetail(for selectedMovie: MovieIdSimilarResponse.Result) {
        guard let movieId = selectedMovie.id else { return }
        
        let movieResult = FavoriteNowPlaying(
            isFavorite: false,
            posterPath: selectedMovie.posterPath,
            adult: selectedMovie.adult,
            overview: selectedMovie.overview,
            releaseDate: selectedMovie.releaseDate,
            genreIDS: selectedMovie.genreIDS,
            id: selectedMovie.id,
            originalTitle: selectedMovie.originalTitle,
            originalLanguage: selectedMovie.originalLanguage,
            title: selectedMovie.title,
            backdropPath: selectedMovie.backdropPath,
            popularity: selectedMovie.popularity,
            voteCount: selectedMovie.voteCount,
            video: selectedMovie.video,
            voteAverage: selectedMovie.voteAverage
        )
        
        let detailVC = MovieDetailsViewController()
        detailVC.hidesBottomBarWhenPushed = true
        let vm = DefaultMovieDetailsViewModel(
            movieId: movieId,
            movieResult: movieResult,
            useCase: DefaultFetchMovieSimilarUseCase(
                repository: DefaultBaseMovieRepository(
                    remoteData: DefaultBaseRemoteMovies(),
                    localData: DefaultBaseLocalMovies()
                )
            )
        )
        detailVC.viewModel = vm
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - UIScrollViewDelegate (Parallax & Navbar Fade)
extension MovieDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // Navbar Alpha Fade
        navBarView.setAlphaProgress(offsetY / 160.0)
        
        // Stretchy Parallax Header on Pull Down
        headerView.applyParallax(offsetY: offsetY)
    }
}
