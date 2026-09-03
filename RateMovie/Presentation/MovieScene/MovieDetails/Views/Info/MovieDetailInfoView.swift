//
//  MovieDetailInfoView.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import UIKit
import Kingfisher

class MovieDetailInfoView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var posterContainerView: UIView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
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
    
    private let goldRatingColor = UIColor(red: 245/255, green: 197/255, blue: 24/255, alpha: 1.0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        posterContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: posterContainerView.bounds,
            cornerRadius: 14
        ).cgPath
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
        setupStyle()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateStyles()
        }
    }
    
    private func updateStyles() {
        titleLabel.textColor = RMColor.textPrimary
        taglineLabel.textColor = RMColor.textSecondary
        ratingLabel.textColor = RMColor.accentRating
        voteCountLabel.textColor = RMColor.textSecondary
        [yearLabel, durationLabel, languageLabel].forEach { label in
            label?.textColor = RMColor.textPrimary
        }
        
        posterImageView.backgroundColor = RMColor.surfaceBadge
        posterImageView.layer.borderColor = RMColor.borderEmphasis.cgColor
        
        ratingBadgeView.backgroundColor = RMColor.surfaceCard
        ratingBadgeView.layer.borderColor = RMColor.accentRating.withAlphaComponent(0.4).cgColor
        
        [yearBadgeView, durationBadgeView, languageBadgeView].forEach { badge in
            badge?.backgroundColor = RMColor.surfaceCard
            badge?.layer.borderColor = RMColor.borderSubtle.cgColor
        }
    }
    
    private func setupStyle() {
        // Poster Styling & Ambient Depth
        posterImageView.layer.cornerRadius = 14
        posterImageView.layer.borderWidth = 0.8
        
        posterContainerView.layer.shadowColor = UIColor.black.cgColor
        posterContainerView.layer.shadowOpacity = 0.18
        posterContainerView.layer.shadowOffset = CGSize(width: 0, height: 6)
        posterContainerView.layer.shadowRadius = 12
        
        // Rating Badge
        ratingBadgeView.layer.cornerRadius = 8
        ratingBadgeView.layer.borderWidth = 0.5
        
        // Metadata Badges
        [yearBadgeView, durationBadgeView, languageBadgeView].forEach { badge in
            badge?.layer.cornerRadius = 8
            badge?.layer.borderWidth = 0.5
        }
        
        updateStyles()
    }
}

extension MovieDetailInfoView {
    func setView(with viewModel: MovieDetailInfoViewModel) {
        titleLabel.text = viewModel.title
        
        if let tagline = viewModel.tagline {
            taglineLabel.text = tagline
            taglineLabel.isHidden = false
        } else {
            taglineLabel.isHidden = true
        }
        
        if let poster = viewModel.posterURL {
            posterImageView.kf.indicatorType = .activity
            posterImageView.kf.setImage(
                with: poster,
                placeholder: nil,
                options: [.transition(.fade(0.3))]
            )
        }
        
        // Rating & Vote Count
        ratingLabel.text = viewModel.rating
        if let voteCount = viewModel.voteCount {
            voteCountLabel.text = voteCount
            voteCountLabel.isHidden = false
        } else {
            voteCountLabel.isHidden = true
        }
        
        // Year
        if let year = viewModel.releaseYear {
            yearLabel.text = year
            yearBadgeView.isHidden = false
        } else {
            yearBadgeView.isHidden = true
        }
        
        // Runtime
        if let duration = viewModel.runtime {
            durationLabel.text = duration
            durationBadgeView.isHidden = false
        } else {
            durationBadgeView.isHidden = true
        }
        
        // Language
        if let lang = viewModel.language {
            languageLabel.text = lang
            languageBadgeView.isHidden = false
        } else {
            languageBadgeView.isHidden = true
        }
    }
}
