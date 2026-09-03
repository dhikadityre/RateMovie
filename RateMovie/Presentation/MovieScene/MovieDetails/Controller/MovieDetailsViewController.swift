//
//  MovieDetailsViewController.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 07/10/22.
//

import UIKit
import SwiftUI

class MovieDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets (Modular Custom Views)
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var navBarView: MovieDetailNavBarView!
    @IBOutlet weak var headerView: MovieDetailHeaderView!
    @IBOutlet weak var infoView: MovieDetailInfoView!
    @IBOutlet weak var genresView: MovieDetailGenresView!
    @IBOutlet weak var storylineView: MovieDetailStorylineView!
    @IBOutlet weak var similarView: MovieDetailSimilarView!
    
    // MARK: - SwiftUI Embedded Component
    private(set) var ratingHostingController: UIHostingController<InteractiveRatingWidgetView>?
    private(set) var ratingViewModel = InteractiveRatingWidgetViewModel()
    
    // MARK: - Booking UI Components
    private(set) var bottomBookingBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = RMColor.surfaceCard
        return view
    }()
    
    private(set) var bookTicketButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Book Ticket", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = RMColor.brandPrimary
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
            let image = UIImage(systemName: "ticket.fill", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .white
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
        return button
    }()
    
    // MARK: - ViewModel
    var viewModel: MovieDetailsViewModel?
    
    // MARK: - Persistence Manager
    public var ticketPersistenceManager: TicketPersistenceManagerProtocol = TicketPersistenceManager.shared
}

// MARK: - Lifecycle
extension MovieDetailsViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
        }
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
        view.backgroundColor = RMColor.backgroundPrimary
        scrollView.backgroundColor = RMColor.backgroundPrimary
        scrollView.delegate = self
        setupRatingWidget()
        setupBookingBar()
        updateComponents()
    }
    
    private func setupRatingWidget() {
        guard let contentStackView = contentStackView else { return }
        
        let ratingVM = InteractiveRatingWidgetViewModel(
            movieTitle: viewModel?.title,
            onRatingSubmitted: { [weak self] _ in
                self?.snakeBarGreen(message: "Thank you for rating!")
            }
        )
        self.ratingViewModel = ratingVM
        
        let hostingController = UIHostingController(rootView: InteractiveRatingWidgetView(viewModel: ratingVM))
        hostingController.view.backgroundColor = .clear
        
        addChild(hostingController)
        
        if let similarIndex = contentStackView.arrangedSubviews.firstIndex(of: similarView) {
            contentStackView.insertArrangedSubview(hostingController.view, at: similarIndex)
        } else {
            contentStackView.addArrangedSubview(hostingController.view)
        }
        
        hostingController.didMove(toParent: self)
        self.ratingHostingController = hostingController
    }
    
    private func setupBookingBar() {
        view.addSubview(bottomBookingBar)
        bottomBookingBar.addSubview(bookTicketButton)
        
        bottomBookingBar.layer.shadowColor = UIColor.black.cgColor
        bottomBookingBar.layer.shadowOpacity = 0.08
        bottomBookingBar.layer.shadowOffset = CGSize(width: 0, height: -4)
        bottomBookingBar.layer.shadowRadius = 12
        
        NSLayoutConstraint.activate([
            bottomBookingBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBookingBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBookingBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bookTicketButton.leadingAnchor.constraint(equalTo: bottomBookingBar.leadingAnchor, constant: 20),
            bookTicketButton.trailingAnchor.constraint(equalTo: bottomBookingBar.trailingAnchor, constant: -20),
            bookTicketButton.topAnchor.constraint(equalTo: bottomBookingBar.topAnchor, constant: 12),
            bookTicketButton.bottomAnchor.constraint(equalTo: bottomBookingBar.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            bookTicketButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        scrollView.contentInset.bottom = 90
        if #available(iOS 13.0, *) {
            scrollView.verticalScrollIndicatorInsets.bottom = 90
        }
        
        bookTicketButton.addTarget(self, action: #selector(didTapBookTicket), for: .touchUpInside)
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
    
    @objc func didTapBookTicket() {
        navigateToSeatBooking()
    }
    
    func navigateToSeatBooking() {
        let movieId = viewModel?.getMovieId()
        let movieTitle = viewModel?.title ?? "Movie Details"
        
        let bookingVM = SeatBookingViewModel(
            movieId: movieId,
            movieTitle: movieTitle,
            onConfirmBooking: { [weak self] summary in
                self?.handleBookingConfirmation(summary: summary)
            }
        )
        let bookingView = SeatBookingView(viewModel: bookingVM)
        let hostingController = UIHostingController(rootView: bookingView)
        hostingController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    public func handleBookingConfirmation(summary: SeatBookingSummary, completion: ((Result<TicketModel, Error>) -> Void)? = nil) {
        let ticketModel = summary.toTicketModel()
        ticketPersistenceManager.saveTicket(ticketModel) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let savedTicket):
                let ticketPassVC = TicketPassViewController(summary: summary, onDone: { [weak self] in
                    guard let self = self else { return }
                    self.navigationController?.popToViewController(self, animated: true)
                })
                self.navigationController?.pushViewController(ticketPassVC, animated: true)
                completion?(.success(savedTicket))
            case .failure(let error):
                let ticketPassVC = TicketPassViewController(summary: summary, onDone: { [weak self] in
                    guard let self = self else { return }
                    self.navigationController?.popToViewController(self, animated: true)
                })
                self.navigationController?.pushViewController(ticketPassVC, animated: true)
                completion?(.failure(error))
            }
        }
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
