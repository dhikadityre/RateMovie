//
//  UserProfileModel.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import Foundation

public struct UserProfileModel: Equatable {
    public var name: String
    public var email: String
    public var memberTier: String
    public var joinDate: String
    public var avatarImageName: String?
    public var totalWatchHours: Double
    public var totalFavoritesCount: Int
    public var totalTicketsCount: Int
    public var totalReviewsCount: Int
    
    public init(
        name: String = "Dhika Aditya",
        email: String = "dhika.aditya@ratemovie.io",
        memberTier: String = "VIP Cinephile",
        joinDate: String = "Member since 2022",
        avatarImageName: String? = nil,
        totalWatchHours: Double = 0.0,
        totalFavoritesCount: Int = 0,
        totalTicketsCount: Int = 0,
        totalReviewsCount: Int = 0
    ) {
        self.name = name
        self.email = email
        self.memberTier = memberTier
        self.joinDate = joinDate
        self.avatarImageName = avatarImageName
        self.totalWatchHours = totalWatchHours
        self.totalFavoritesCount = totalFavoritesCount
        self.totalTicketsCount = totalTicketsCount
        self.totalReviewsCount = totalReviewsCount
    }
    
    public var formattedWatchHours: String {
        if totalWatchHours == 0 {
            return "0 hrs"
        } else if totalWatchHours.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(totalWatchHours)) hrs"
        } else {
            return String(format: "%.1f hrs", totalWatchHours)
        }
    }
    
    public var formattedFavorites: String {
        "\(totalFavoritesCount)"
    }
    
    public var formattedTickets: String {
        "\(totalTicketsCount)"
    }
    
    public var formattedReviews: String {
        "\(totalReviewsCount)"
    }
}
