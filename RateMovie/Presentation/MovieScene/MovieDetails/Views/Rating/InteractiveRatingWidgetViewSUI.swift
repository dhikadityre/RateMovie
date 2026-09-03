//
//  InteractiveRatingWidgetViewSUI.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import SwiftUI

public struct InteractiveRatingWidgetViewSUI: View {
    @ObservedObject public var viewModel: InteractiveRatingWidgetViewModelSUI

    public init(viewModel: InteractiveRatingWidgetViewModelSUI) {
        self.viewModel = viewModel
    }
    
    public var body: some View { render() }
    
    private func render() -> some View {
        renderCardContainer()
    }
}

// MARK: - Main Content & Container
extension InteractiveRatingWidgetViewSUI {
    private func renderCardContainer() -> some View {
        VStack(alignment: .center, spacing: 14) {
            renderHeaderSection()
            renderStarRatingRow()
            renderSentimentDescription()
            renderActionSection()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(RMColor.surfaceCard))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(RMColor.borderSubtle), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Header Section
extension InteractiveRatingWidgetViewSUI {
    private func renderHeaderIconAndTitle() -> some View {
        HStack(spacing: 8) {
            Image(systemName: "star.bubble.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(RMColor.brandPrimary))
            
            Text("Rate & Review")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(RMColor.textPrimary))
        }
    }
    
    @ViewBuilder
    private func renderScoreBadge() -> some View {
        if viewModel.hasRating {
            Text(viewModel.ratingScoreFormatted)
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(Color(RMColor.accentRating))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(RMColor.accentRating).opacity(0.12))
                )
        }
    }
    
    private func renderHeaderSection() -> some View {
        HStack {
            renderHeaderIconAndTitle()
            Spacer()
            renderScoreBadge()
        }
    }
}

// MARK: - Star Rating Section
extension InteractiveRatingWidgetViewSUI {
    private func renderStarItem(for index: Int) -> some View {
        let isSelected = index <= viewModel.currentRating
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                viewModel.selectRating(index)
            }
        }) {
            Image(systemName: isSelected ? "star.fill" : "star")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(isSelected ? Color(RMColor.accentRating) : Color(RMColor.textTertiary).opacity(0.5))
                .scaleEffect(index == viewModel.currentRating ? 1.15 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func renderStarRatingRow() -> some View {
        HStack(spacing: 12) {
            ForEach(1...viewModel.maxRating, id: \.self) { starIndex in
                renderStarItem(for: starIndex)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Sentiment Description
extension InteractiveRatingWidgetViewSUI {
    private func renderSentimentDescription() -> some View {
        Text(viewModel.sentimentDescription)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(viewModel.hasRating ? Color(RMColor.textSecondary) : Color(RMColor.textTertiary))
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: viewModel.currentRating)
    }
}

// MARK: - Action Section (Submit / Thank You)
extension InteractiveRatingWidgetViewSUI {
    private func renderThankYouMessage() -> some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 14, weight: .semibold))
            
            Text("Thank you for your rating!")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(RMColor.textPrimary))
        }
        .padding(.top, 4)
        .transition(.scale.combined(with: .opacity))
    }
    
    private func renderSubmitButton() -> some View {
        Button(action: {
            withAnimation(.spring()) {
                viewModel.submitRating()
            }
        }) {
            HStack(spacing: 6) {
                Text("Submit Rating")
                    .font(.system(size: 13, weight: .semibold))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(RMColor.brandPrimary))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.top, 2)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    @ViewBuilder
    private func renderActionSection() -> some View {
        if viewModel.isSubmitted {
            renderThankYouMessage()
        } else if viewModel.hasRating {
            renderSubmitButton()
        }
    }
}
