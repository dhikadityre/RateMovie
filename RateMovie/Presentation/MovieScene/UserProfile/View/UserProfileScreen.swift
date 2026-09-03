//
//  UserProfileScreen.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import SwiftUI

struct UserProfileScreen: View {
    @ObservedObject var viewModel: UserProfileScreenViewModel
    
    init(viewModel: UserProfileScreenViewModel = UserProfileScreenViewModel()) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        render()
            .onAppear {
                viewModel.fetchUserProfileData()
            }
    }
    
    private func render() -> some View {
        ZStack {
            Color(RMColor.backgroundPrimary)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    renderHeaderCard()
                    renderStatisticsGrid()
                    renderNavigationActions()
                    if !viewModel.recentTickets.isEmpty {
                        renderRecentTicketsSection()
                    }
                    renderPerksCard()
                    renderPreferencesSection()
                    
                    Spacer()
                        .frame(height: 32)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
        }
        .navigationBarTitle("User Profile", displayMode: .inline)
    }
}

// MARK: - Header Profile Card
extension UserProfileScreen {
    private func renderAvatarView() -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(RMColor.brandPrimary),
                            Color(RMColor.brandSecondary)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 76, height: 76)
                .shadow(color: Color(RMColor.brandPrimary).opacity(0.35), radius: 10, x: 0, y: 5)
            
            Text("DA")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .overlay(
            Circle()
                .stroke(Color(RMColor.surfaceCard), lineWidth: 3)
        )
    }
    
    private func renderUserInfo() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(viewModel.profile.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(RMColor.textPrimary))
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color(RMColor.brandPrimary))
            }
            
            Text(viewModel.profile.email)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(RMColor.textSecondary))
            
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(RMColor.accentRating))
                    
                    Text(viewModel.profile.memberTier)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(RMColor.accentRating))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(Color(RMColor.accentRating).opacity(0.12))
                )
                
                Text(viewModel.profile.joinDate)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(RMColor.textTertiary))
            }
            .padding(.top, 4)
        }
    }
    
    private func renderHeaderCard() -> some View {
        HStack(spacing: 16) {
            renderAvatarView()
            renderUserInfo()
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(RMColor.surfaceCard))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(RMColor.borderSubtle), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Core Data Statistics Grid
extension UserProfileScreen {
    private func renderStatCard(
        title: String,
        value: String,
        iconName: String,
        tintColor: Color,
        subtitle: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(tintColor.opacity(0.12))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tintColor)
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(RMColor.textPrimary))
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(RMColor.textSecondary))
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(RMColor.textTertiary))
                    .lineLimit(1)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(RMColor.surfaceCard))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(RMColor.borderSubtle), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 3)
        )
    }
    
    private func renderStatisticsGrid() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cinema Activity")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(RMColor.textPrimary))
                .padding(.leading, 4)
            
            HStack(spacing: 12) {
                renderStatCard(
                    title: "Watch Time",
                    value: viewModel.profile.formattedWatchHours,
                    iconName: "clock.fill",
                    tintColor: Color(RMColor.accentRating),
                    subtitle: "Calculated duration"
                )
                
                renderStatCard(
                    title: "My Favorites",
                    value: viewModel.profile.formattedFavorites,
                    iconName: "heart.fill",
                    tintColor: Color(RMColor.accentFavorite),
                    subtitle: "Saved to collection"
                )
            }
            
            HStack(spacing: 12) {
                renderStatCard(
                    title: "Booked Passes",
                    value: viewModel.profile.formattedTickets,
                    iconName: "ticket.fill",
                    tintColor: Color(RMColor.brandPrimary),
                    subtitle: "Stored in Core Data"
                )
                
                renderStatCard(
                    title: "Reviews Given",
                    value: viewModel.profile.formattedReviews,
                    iconName: "star.bubble.fill",
                    tintColor: Color.purple,
                    subtitle: "Community feedback"
                )
            }
        }
    }
}

// MARK: - Navigation Action Section
extension UserProfileScreen {
    private func renderActionRow(
        icon: String,
        iconBgColor: Color,
        title: String,
        subtitle: String,
        badgeText: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(iconBgColor.opacity(0.14))
                        .frame(width: 42, height: 42)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconBgColor)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(RMColor.textPrimary))
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(RMColor.textSecondary))
                }
                
                Spacer()
                
                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(iconBgColor)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(iconBgColor.opacity(0.12))
                        )
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(RMColor.textTertiary))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(RMColor.surfaceCard))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(RMColor.borderSubtle), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func renderNavigationActions() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(RMColor.textPrimary))
                .padding(.leading, 4)
            
            VStack(spacing: 10) {
                renderActionRow(
                    icon: "heart.fill",
                    iconBgColor: Color(RMColor.accentFavorite),
                    title: "My Favorites",
                    subtitle: "View and manage your saved movies",
                    badgeText: "\(viewModel.profile.totalFavoritesCount) Movies",
                    action: {
                        viewModel.didTapFavorites()
                    }
                )
                
                renderActionRow(
                    icon: "ticket.fill",
                    iconBgColor: Color(RMColor.brandPrimary),
                    title: "Ticket Passes",
                    subtitle: "View active cinema passes & QR codes",
                    badgeText: "\(viewModel.profile.totalTicketsCount) Passes",
                    action: {
                        viewModel.didTapTickets()
                    }
                )
            }
        }
    }
}

// MARK: - Recent Tickets Section
extension UserProfileScreen {
    private func renderRecentTicketsSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Passes")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(RMColor.textPrimary))
                
                Spacer()
                
                Text("\(viewModel.recentTickets.count) Total")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(RMColor.textTertiary))
            }
            .padding(.leading, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recentTickets, id: \.ticketId) { ticket in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "film")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(RMColor.brandPrimary))
                                
                                Text(ticket.movieTitle ?? "Cinema Ticket")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(Color(RMColor.textPrimary))
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("SHOWTIME")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(Color(RMColor.textTertiary))
                                    Text(ticket.showtime ?? "-")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(Color(RMColor.textSecondary))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("SEATS")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(Color(RMColor.textTertiary))
                                    Text(ticket.seats ?? "-")
                                        .font(.system(size: 11, weight: .heavy))
                                        .foregroundColor(Color(RMColor.brandPrimary))
                                }
                            }
                        }
                        .padding(12)
                        .frame(width: 220)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(RMColor.surfaceCard))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color(RMColor.borderSubtle), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - VIP Perks Card
extension UserProfileScreen {
    private func renderPerksCard() -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(RMColor.accentRating).opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(RMColor.accentRating))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Cinephile Club Privilege")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(RMColor.textPrimary))
                
                Text("Enjoy 10% discount on all IMAX & Dolby Atmos screenings")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(RMColor.textSecondary))
            }
            
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(RMColor.surfaceCard))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(RMColor.accentRating).opacity(0.25), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preferences & Support Section
extension UserProfileScreen {
    private func renderPreferenceRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(RMColor.textSecondary))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(RMColor.textPrimary))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(RMColor.textTertiary))
        }
        .padding(.vertical, 8)
    }
    
    private func renderPreferencesSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("App & Settings")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(RMColor.textPrimary))
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                renderPreferenceRow(icon: "tv.fill", title: "Stream Quality", value: "4K Ultra HD")
                Divider().background(Color(RMColor.borderSubtle))
                renderPreferenceRow(icon: "bell.fill", title: "Notifications", value: "Enabled")
                Divider().background(Color(RMColor.borderSubtle))
                renderPreferenceRow(icon: "info.circle.fill", title: "App Version", value: "v1.2.0 (Build 42)")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(RMColor.surfaceCard))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(RMColor.borderSubtle), lineWidth: 1)
                    )
            )
        }
    }
}

#if DEBUG
struct UserProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserProfileScreen(
                viewModel: UserProfileScreenViewModel(
                    profile: UserProfileModel(
                        name: "Dhika Aditya",
                        email: "dhika.aditya@ratemovie.io",
                        memberTier: "VIP Cinephile",
                        joinDate: "Member since 2022",
                        totalWatchHours: 24.5,
                        totalFavoritesCount: 14,
                        totalTicketsCount: 6,
                        totalReviewsCount: 5
                    )
                )
            )
            .preferredColorScheme(.dark)
            
            UserProfileScreen(
                viewModel: UserProfileScreenViewModel(
                    profile: UserProfileModel(
                        name: "Dhika Aditya",
                        email: "dhika.aditya@ratemovie.io",
                        memberTier: "VIP Cinephile",
                        joinDate: "Member since 2022",
                        totalWatchHours: 24.5,
                        totalFavoritesCount: 14,
                        totalTicketsCount: 6,
                        totalReviewsCount: 5
                    )
                )
            )
            .preferredColorScheme(.light)
        }
    }
}
#endif
