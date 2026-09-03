//
//  MovieItemCollectionViewCell.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import UIKit
import Kingfisher

class MovieItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var favoriteView: UIView!
    @IBOutlet weak var moviePreviewImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieRateLabel: UILabel!
    @IBOutlet weak var movieLanguageLabel: UILabel!
    @IBOutlet weak var movieFavoriteImageView: UIImageView!
    
    var onFavouriteTapped: (() -> Void)?
    
    static let identifier = "MovieItemCollectionViewCell"
    static func nib() -> UINib {
        UINib(nibName: identifier, bundle: nil)
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseInOut, .allowUserInteraction]
            ) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupGesture()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        moviePreviewImageView.kf.cancelDownloadTask()
        moviePreviewImageView.image = nil
        movieTitleLabel.text = nil
        movieRateLabel.text = nil
        movieLanguageLabel.text = nil
        transform = .identity
    }
    
    private func setupUI() {
        // Container styling & smooth ambient shadow
        containerView.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 32/255, alpha: 1.0)
        containerView.layer.cornerRadius = 14
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.22
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        
        // Poster Image
        moviePreviewImageView.contentMode = .scaleAspectFill
        moviePreviewImageView.clipsToBounds = true
        moviePreviewImageView.layer.cornerRadius = 14
        moviePreviewImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        moviePreviewImageView.backgroundColor = UIColor(red: 40/255, green: 40/255, blue: 45/255, alpha: 1.0)
        
        // Favorite button (Frosted circular look)
        favoriteView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        favoriteView.layer.cornerRadius = 16
        favoriteView.clipsToBounds = true
        favoriteView.layer.borderWidth = 0.5
        favoriteView.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        
        movieFavoriteImageView.tintColor = .systemPink
        
        // Language badge (Pill style)
        if let langContainer = movieLanguageLabel.superview {
            langContainer.backgroundColor = UIColor.black.withAlphaComponent(0.65)
            langContainer.layer.cornerRadius = 6
            langContainer.clipsToBounds = true
            langContainer.layer.borderWidth = 0.5
            langContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        }
        movieLanguageLabel.textColor = .white
        movieLanguageLabel.font = .systemFont(ofSize: 10, weight: .bold)
        
        // Typography
        movieTitleLabel.textColor = .white
        movieTitleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        
        movieRateLabel.textColor = UIColor(red: 245/255, green: 197/255, blue: 24/255, alpha: 1.0)
        movieRateLabel.font = .systemFont(ofSize: 11, weight: .medium)
    }
    
    private func setupGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        favoriteView.isUserInteractionEnabled = true
        favoriteView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        UIView.animate(withDuration: 0.12, animations: {
            self.favoriteView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                self.favoriteView.transform = .identity
            }
        }
        
        onFavouriteTapped?()
    }
    
    public func setFavorite(isFavorite: Bool, animated: Bool = false) {
        let imageName = isFavorite ? "bookmark.fill" : "bookmark"
        let newImage = UIImage(systemName: imageName)
        
        if animated {
            UIView.transition(
                with: movieFavoriteImageView,
                duration: 0.2,
                options: .transitionCrossDissolve
            ) {
                self.movieFavoriteImageView.image = newImage
            }
        } else {
            movieFavoriteImageView.image = newImage
        }
    }
    
    public func configure(
        title: String?,
        rating: Double?,
        language: String?,
        posterPath: String?,
        isFavorite: Bool
    ) {
        movieTitleLabel.text = title ?? "-"
        
        if let rating = rating, rating > 0 {
            let formattedRating = String(format: "%.1f", rating)
            movieRateLabel.text = "★ \(formattedRating)"
            movieRateLabel.isHidden = false
        } else {
            movieRateLabel.text = "★ N/A"
        }
        
        if let lang = language, !lang.isEmpty {
            movieLanguageLabel.text = lang.uppercased()
            movieLanguageLabel.superview?.isHidden = false
        } else {
            movieLanguageLabel.superview?.isHidden = true
        }
        
        setFavorite(isFavorite: isFavorite)
        
        if let poster = posterPath, let imageUrl = URL(string: Endpoint.Images.baseImage + poster) {
            moviePreviewImageView.kf.indicatorType = .activity
            moviePreviewImageView.kf.setImage(
                with: imageUrl,
                placeholder: nil,
                options: [.transition(.fade(0.25))]
            )
        } else {
            moviePreviewImageView.image = UIImage(systemName: "film")
            moviePreviewImageView.tintColor = .darkGray
        }
    }
    
    public func setView(
        movieTitle: String,
        movieRate: String,
        movieLanguage: String
    ) {
        movieTitleLabel.text = movieTitle
        movieRateLabel.text = movieRate
        movieLanguageLabel.text = movieLanguage.uppercased()
    }
    
    public func setMovieFavoriteImageView(status: Bool) {
        setFavorite(isFavorite: status)
    }
}
