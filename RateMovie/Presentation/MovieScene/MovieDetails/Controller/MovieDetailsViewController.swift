//
//  MovieDetailsViewController.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 07/10/22.
//

import UIKit
import Kingfisher

class MovieDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets (Setup via Auto Layout in XIB)
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var gradientOverlayView: UIView!
    @IBOutlet weak var posterContainerView: UIView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var titleMovieLabel: UILabel!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var ratingBadgeView: UIView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var yearBadgeView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var durationBadgeView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var languageBadgeView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var genreScrollView: UIScrollView!
    @IBOutlet weak var genreStackView: UIStackView!
    @IBOutlet weak var storylineTitleLabel: UILabel!
    @IBOutlet weak var overviewDescriptionLabel: UILabel!
    @IBOutlet weak var readMoreButton: UIButton!
    @IBOutlet weak var similarTitleLabel: UILabel!
    @IBOutlet weak var recommendationCollectionView: UICollectionView!
    @IBOutlet weak var recommendationCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var emptyRecommendationsLabel: UILabel!
    @IBOutlet weak var floatingNavBar: UIView!
    @IBOutlet weak var navBlurView: UIVisualEffectView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    // MARK: - ViewModel
    var viewModel: MovieDetailsViewModel?
    
    // MARK: - UI State & Layers
    private let gradientLayer = CAGradientLayer()
    private var isOverviewExpanded = false
    private let darkBackground = UIColor(red: 16/255, green: 17/255, blue: 21/255, alpha: 1.0)
    private let goldRatingColor = UIColor(red: 245/255, green: 197/255, blue: 24/255, alpha: 1.0)
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
        setupActions()
        configureCollectionView()
        bind()
        viewModel?.didLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientOverlayView.bounds
        posterContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: posterContainerView.bounds,
            cornerRadius: 14
        ).cgPath
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - UI Styling & Initial Configuration
extension MovieDetailsViewController {
    
    private func setupUI() {
        // Base View Styling
        view.backgroundColor = darkBackground
        scrollView.delegate = self
        
        // Header Image & Multi-stop Gradient Overlay
        headerImageView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1.0)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.clear.cgColor,
            darkBackground.withAlphaComponent(0.7).cgColor,
            darkBackground.cgColor
        ]
        gradientLayer.locations = [0.0, 0.40, 0.78, 1.0]
        gradientOverlayView.layer.addSublayer(gradientLayer)
        
        // Poster Styling & Ambient Depth
        contentImageView.layer.cornerRadius = 14
        contentImageView.layer.borderWidth = 0.8
        contentImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        
        posterContainerView.layer.shadowColor = UIColor.black.cgColor
        posterContainerView.layer.shadowOpacity = 0.55
        posterContainerView.layer.shadowOffset = CGSize(width: 0, height: 8)
        posterContainerView.layer.shadowRadius = 14
        
        // Metadata Badge Badges Styling
        ratingBadgeView.layer.cornerRadius = 8
        ratingBadgeView.layer.borderWidth = 0.5
        ratingBadgeView.layer.borderColor = goldRatingColor.withAlphaComponent(0.4).cgColor
        
        [yearBadgeView, durationBadgeView, languageBadgeView].forEach { badge in
            badge?.layer.cornerRadius = 8
            badge?.layer.borderWidth = 0.5
            badge?.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        }
        
        // Floating Nav Bar Button Styling
        styleCircleButton(backButton, systemName: "chevron.left")
        styleCircleButton(shareButton, systemName: "square.and.arrow.up")
        styleCircleButton(favoriteButton, systemName: "bookmark")
        
        // Populate initial data from ViewModel
        populateInitialData()
    }
    
    private func styleCircleButton(_ button: UIButton, systemName: String) {
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let image = UIImage(systemName: systemName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(didTapFavorite), for: .touchUpInside)
        readMoreButton.addTarget(self, action: #selector(toggleOverviewExpanded), for: .touchUpInside)
    }
    
    private func configureCollectionView() {
        recommendationCollectionView.delegate = self
        recommendationCollectionView.dataSource = self
        recommendationCollectionView.register(
            MovieItemCollectionViewCell.nib(),
            forCellWithReuseIdentifier: MovieItemCollectionViewCell.identifier
        )
    }
    
    private func populateInitialData() {
        guard let vm = viewModel else { return }
        
        titleMovieLabel.text = vm.title
        navTitleLabel.text = vm.title
        
        if let backdrop = vm.backdropURL {
            headerImageView.kf.indicatorType = .activity
            headerImageView.kf.setImage(
                with: backdrop,
                placeholder: nil,
                options: [.transition(.fade(0.3))]
            )
        }
        
        if let poster = vm.posterURL {
            contentImageView.kf.indicatorType = .activity
            contentImageView.kf.setImage(
                with: poster,
                placeholder: nil,
                options: [.transition(.fade(0.3))]
            )
        }
        
        setOverviewText(vm.overview)
        updateMetadata()
    }
    
    private func bind() {
        // Observe Full Movie Details
        viewModel?.movieDetail.observe(on: self) { [weak self] _ in
            guard let self = self, let vm = self.viewModel else { return }
            self.titleMovieLabel.text = vm.title
            self.navTitleLabel.text = vm.title
            
            if let tagline = vm.taglineFormatted {
                self.taglineLabel.text = tagline
                self.taglineLabel.isHidden = false
            } else {
                self.taglineLabel.isHidden = true
            }
            
            self.setOverviewText(vm.overview)
            self.updateMetadata()
            self.updateGenres(genres: vm.genresFormatted)
        }
        
        // Observe Similar Movies
        viewModel?.movieSimilar.observe(on: self) { [weak self] similar in
            guard let self = self else { return }
            self.recommendationCollectionView.reloadData()
            self.emptyRecommendationsLabel.isHidden = !similar.isEmpty
        }
        
        // Observe Favorite Status
        viewModel?.isFavorite.observe(on: self) { [weak self] isFav in
            self?.updateFavoriteButton(isFavorite: isFav, animated: true)
        }
    }
}

// MARK: - Data Binding & Component Updates
extension MovieDetailsViewController {
    
    private func setOverviewText(_ text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let attributed = NSAttributedString(
            string: text,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor(red: 209/255, green: 213/255, blue: 219/255, alpha: 1.0)
            ]
        )
        overviewDescriptionLabel.attributedText = attributed
        readMoreButton.isHidden = text.count < 140
    }
    
    @objc private func toggleOverviewExpanded() {
        isOverviewExpanded.toggle()
        overviewDescriptionLabel.numberOfLines = isOverviewExpanded ? 0 : 4
        readMoreButton.setTitle(isOverviewExpanded ? "Read Less" : "Read More", for: .normal)
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateMetadata() {
        guard let vm = viewModel else { return }
        
        // Rating & Vote Count
        ratingLabel.text = vm.ratingFormatted
        if let voteCount = vm.voteCountFormatted {
            voteCountLabel.text = voteCount
            voteCountLabel.isHidden = false
        } else {
            voteCountLabel.isHidden = true
        }
        
        // Release Year
        if let year = vm.releaseYearFormatted {
            yearLabel.text = year
            yearBadgeView.isHidden = false
        } else {
            yearBadgeView.isHidden = true
        }
        
        // Duration / Runtime
        if let duration = vm.runtimeFormatted {
            durationLabel.text = duration
            durationBadgeView.isHidden = false
        } else {
            durationBadgeView.isHidden = true
        }
        
        // Language
        if let lang = vm.languageFormatted {
            languageLabel.text = lang
            languageBadgeView.isHidden = false
        } else {
            languageBadgeView.isHidden = true
        }
    }
    
    private func updateGenres(genres: [String]) {
        genreStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        genreScrollView.isHidden = genres.isEmpty
        
        for genre in genres {
            let chip = makeGenreChip(title: genre)
            genreStackView.addArrangedSubview(chip)
        }
    }
    
    private func makeGenreChip(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 35/255, green: 37/255, blue: 46/255, alpha: 0.85)
        container.layer.cornerRadius = 12
        container.layer.borderWidth = 0.5
        container.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
        ])
        
        return container
    }
}

// MARK: - Actions & Interactions
extension MovieDetailsViewController {
    
    @objc private func didTapBack() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didTapShare() {
        guard let vm = viewModel else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        let shareText = "Check out \(vm.title) (Rating: ★ \(vm.ratingFormatted)) on RateMovie!\n\n\(vm.overview)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = shareButton
        present(activityVC, animated: true)
    }
    
    @objc private func didTapFavorite() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.12, animations: {
            self.favoriteButton.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                self.favoriteButton.transform = .identity
            }
        }
        
        viewModel?.toggleFavorite()
    }
    
    private func updateFavoriteButton(isFavorite: Bool, animated: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let imageName = isFavorite ? "bookmark.fill" : "bookmark"
        let image = UIImage(systemName: imageName, withConfiguration: config)
        let tintColor: UIColor = isFavorite ? .systemPink : .white
        
        if animated {
            UIView.transition(with: favoriteButton, duration: 0.25, options: .transitionCrossDissolve) {
                self.favoriteButton.setImage(image, for: .normal)
                self.favoriteButton.tintColor = tintColor
            }
        } else {
            favoriteButton.setImage(image, for: .normal)
            favoriteButton.tintColor = tintColor
        }
    }
}

// MARK: - UIScrollViewDelegate (Parallax & Navbar Fade)
extension MovieDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        
        // Navbar Alpha Fade
        let threshold: CGFloat = 160
        let alpha = min(max(offsetY / threshold, 0), 1.0)
        navBlurView.alpha = alpha
        navTitleLabel.alpha = alpha
        
        // Stretchy Parallax Header on Pull Down
        if offsetY < 0 {
            headerImageView.transform = CGAffineTransform(translationX: 0, y: offsetY / 2)
                .scaledBy(x: 1 - offsetY / 300, y: 1 - offsetY / 300)
        } else {
            headerImageView.transform = .identity
        }
    }
}
