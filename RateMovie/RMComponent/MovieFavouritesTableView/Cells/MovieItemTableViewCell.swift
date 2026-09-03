//
//  MovieItemTableViewCell.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import UIKit
import Kingfisher

public class MovieItemTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var moviePreviewImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var favoriteContainerView: UIView?
    @IBOutlet weak var languageContainerView: UIView?
    @IBOutlet weak var languageLabel: UILabel?
    
    public var onTapFavourite: (() -> Void)?
    
    public static let identifier = "MovieItemTableViewCell"
    public static func nib() -> UINib {
        UINib(nibName: identifier, bundle: Bundle(for: self.self))
    }
    
    public override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.5,
                options: [.curveEaseInOut, .allowUserInteraction]
            ) {
                self.customContentView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupGesture()
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        moviePreviewImageView.kf.cancelDownloadTask()
        moviePreviewImageView.image = nil
        titleLabel.text = nil
        rateLabel.text = nil
        languageLabel?.text = nil
        customContentView.transform = .identity
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateBorderColors()
        }
    }
    
    private func updateBorderColors() {
        customContentView.layer.borderColor = RMColor.borderSubtle.cgColor
        (favoriteContainerView ?? favoriteImageView)?.layer.borderColor = RMColor.borderEmphasis.cgColor
        languageContainerView?.layer.borderColor = RMColor.borderSubtle.cgColor
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Card Container Styling & Shadow
        customContentView.backgroundColor = RMColor.surfaceCard
        customContentView.layer.cornerRadius = 14
        customContentView.layer.borderWidth = 0.5
        customContentView.layer.borderColor = RMColor.borderSubtle.cgColor
        customContentView.layer.masksToBounds = false
        customContentView.layer.shadowColor = UIColor.black.cgColor
        customContentView.layer.shadowOpacity = 0.12
        customContentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        customContentView.layer.shadowRadius = 6
        
        // Movie Poster Image View
        moviePreviewImageView.contentMode = .scaleAspectFill
        moviePreviewImageView.clipsToBounds = true
        moviePreviewImageView.layer.cornerRadius = 10
        moviePreviewImageView.backgroundColor = RMColor.surfaceBadge
        
        // Favorite Button Container
        let targetFavView = favoriteContainerView ?? favoriteImageView
        targetFavView?.backgroundColor = RMColor.surfaceGlass
        targetFavView?.layer.cornerRadius = 18
        targetFavView?.layer.borderWidth = 0.5
        targetFavView?.layer.borderColor = RMColor.borderEmphasis.cgColor
        targetFavView?.clipsToBounds = true
        
        favoriteImageView.tintColor = RMColor.accentFavorite
        
        // Language Badge Container
        languageContainerView?.backgroundColor = RMColor.surfaceGlass
        languageContainerView?.layer.cornerRadius = 4
        languageContainerView?.layer.borderWidth = 0.5
        languageContainerView?.layer.borderColor = RMColor.borderSubtle.cgColor
        languageContainerView?.clipsToBounds = true
        
        // Typography
        titleLabel.textColor = RMColor.textPrimary
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        
        rateLabel.textColor = RMColor.accentRating
        rateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        
        languageLabel?.textColor = RMColor.textPrimary
        languageLabel?.font = .systemFont(ofSize: 10, weight: .bold)
    }
    
    private func setupGesture() {
        let favTargetView: UIView = favoriteContainerView ?? favoriteImageView
        let favTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapFavourite))
        favTargetView.isUserInteractionEnabled = true
        favTargetView.addGestureRecognizer(favTapGesture)
    }
    
    @objc
    func didTapFavourite() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let targetView: UIView = favoriteContainerView ?? favoriteImageView
        UIView.animate(withDuration: 0.12, animations: {
            targetView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { _ in
            UIView.animate(withDuration: 0.12) {
                targetView.transform = .identity
            }
        }
        
        onTapFavourite?()
    }
    
    public func setFavorite(isFavorite: Bool, animated: Bool = false) {
        let imageName = isFavorite ? "bookmark.fill" : "bookmark"
        let newImage = UIImage(systemName: imageName)
        
        if animated {
            UIView.transition(
                with: favoriteImageView,
                duration: 0.2,
                options: .transitionCrossDissolve
            ) {
                self.favoriteImageView.image = newImage
            }
        } else {
            favoriteImageView.image = newImage
        }
    }
    
    public func configure(
        title: String?,
        rating: Double?,
        language: String?,
        posterPath: String?,
        isFavorite: Bool = true
    ) {
        titleLabel.text = title ?? "-"
        
        if let rating = rating, rating > 0 {
            let formattedRating = String(format: "%.1f", rating)
            rateLabel.text = "★ \(formattedRating)"
            rateLabel.isHidden = false
        } else {
            rateLabel.text = "★ N/A"
        }
        
        if let lang = language, !lang.isEmpty {
            languageLabel?.text = lang.uppercased()
            languageContainerView?.isHidden = false
        } else {
            languageContainerView?.isHidden = true
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
        title: String,
        movieRate: String
    ) {
        titleLabel.text = title
        rateLabel.text = "★ " + movieRate
    }
    
    public func getPreviewImageView() -> UIImageView {
        return moviePreviewImageView
    }
}
