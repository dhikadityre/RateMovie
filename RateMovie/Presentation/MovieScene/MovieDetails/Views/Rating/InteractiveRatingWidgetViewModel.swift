//
//  InteractiveRatingWidgetViewModel.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import Foundation
import Combine

public final class InteractiveRatingWidgetViewModel: ObservableObject {
    @Published public var currentRating: Int
    @Published public var isSubmitted: Bool
    
    public let movieTitle: String?
    public let maxRating: Int
    
    public var onRatingChanged: ((Int) -> Void)?
    public var onRatingSubmitted: ((Int) -> Void)?
    
    public init(
        initialRating: Int = 0,
        maxRating: Int = 5,
        movieTitle: String? = nil,
        isSubmitted: Bool = false,
        onRatingChanged: ((Int) -> Void)? = nil,
        onRatingSubmitted: ((Int) -> Void)? = nil
    ) {
        self.currentRating = initialRating
        self.maxRating = max(1, maxRating)
        self.movieTitle = movieTitle
        self.isSubmitted = isSubmitted
        self.onRatingChanged = onRatingChanged
        self.onRatingSubmitted = onRatingSubmitted
    }
    
    public var hasRating: Bool {
        currentRating > 0
    }
    
    public var ratingScoreFormatted: String {
        "\(currentRating)/\(maxRating)"
    }
    
    public var sentimentDescription: String {
        guard currentRating > 0 else {
            return "Tap a star to share your rating"
        }
        
        switch currentRating {
        case 1:
            return "Terrible 🥱"
        case 2:
            return "Poor 😕"
        case 3:
            return "Average 🙂"
        case 4:
            return "Good! 🍿"
        case 5:
            return "Masterpiece! 🌟"
        default:
            return "\(currentRating) out of \(maxRating)"
        }
    }
    
    // MARK: - User Actions (Setters & Triggers)
    public func selectRating(_ rating: Int) {
        self.currentRating = rating
        self.isSubmitted = false
        self.onRatingChanged?(rating)
    }
    
    public func submitRating() {
        guard currentRating > 0 else { return }
        self.isSubmitted = true
        self.onRatingSubmitted?(currentRating)
    }
    
    public func reset() {
        self.currentRating = 0
        self.isSubmitted = false
    }
}
