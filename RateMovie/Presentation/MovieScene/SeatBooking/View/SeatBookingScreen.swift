//
//  SeatBookingScreen.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import SwiftUI

public struct SeatBookingScreen: View {
    @ObservedObject public var viewModel: SeatBookingScreenViewModel
    
    public init(viewModel: SeatBookingScreenViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        render()
    }
    
    private func render() -> some View {
        ZStack(alignment: .bottom) {
            Color(RMColor.backgroundPrimary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        renderHeaderInfo()
                        renderDatePickerSection()
                        renderTimePickerSection()
                        renderCinemaScreenSection()
                        renderSeatGridSection()
                        renderLegendSection()
                        
                        // Bottom spacing for floating checkout bar
                        Spacer()
                            .frame(height: 90)
                    }
                    .padding(.top, 12)
                }
                
                renderBottomCheckoutBar()
            }
        }
        .navigationBarTitle("Select Seats", displayMode: .inline)
    }
}

// MARK: - Header Info Section
extension SeatBookingScreen {
    private func renderHeaderInfo() -> some View {
        VStack(spacing: 6) {
            Text(viewModel.movieTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(RMColor.textPrimary))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            HStack(spacing: 6) {
                Image(systemName: "film.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(RMColor.brandPrimary))
                
                Text(viewModel.cinemaHall)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(RMColor.textSecondary))
            }
        }
    }
}

// MARK: - Date Picker Section
extension SeatBookingScreen {
    private func renderDateCard(_ date: BookingDate) -> some View {
        let isSelected = date.id == viewModel.selectedDate.id
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                viewModel.selectDate(date)
            }
        }) {
            VStack(spacing: 4) {
                Text(date.dayOfWeek)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(isSelected ? .white : Color(RMColor.textTertiary))
                
                Text(date.dayNumber)
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(isSelected ? .white : Color(RMColor.textPrimary))
                
                Text(date.month)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? .white.opacity(0.85) : Color(RMColor.textSecondary))
            }
            .frame(width: 58, height: 72)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? Color(RMColor.brandPrimary) : Color(RMColor.surfaceCard))
                    .shadow(color: isSelected ? Color(RMColor.brandPrimary).opacity(0.35) : Color.black.opacity(0.03), radius: isSelected ? 8 : 4, x: 0, y: 3)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color(RMColor.borderSubtle), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func renderDatePickerSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(RMColor.textPrimary))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.dates) { date in
                        renderDateCard(date)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Time Picker Section
extension SeatBookingScreen {
    private func renderTimeChip(_ time: BookingTime) -> some View {
        let isSelected = time.id == viewModel.selectedTime.id
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                viewModel.selectTime(time)
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 10))
                Text(time.timeString)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : Color(RMColor.textPrimary))
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isSelected ? Color(RMColor.brandPrimary) : Color(RMColor.surfaceCard))
                    .shadow(color: isSelected ? Color(RMColor.brandPrimary).opacity(0.35) : Color.black.opacity(0.02), radius: 6, x: 0, y: 2)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color(RMColor.borderSubtle), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func renderTimePickerSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Showtime")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(RMColor.textPrimary))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.times) { time in
                        renderTimeChip(time)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Cinema Screen Visual Section
extension SeatBookingScreen {
    private func renderCinemaScreenSection() -> some View {
        VStack(spacing: 8) {
            ZStack {
                // Curved arc representing cinema screen
                ScreenArcShape()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(RMColor.brandPrimary).opacity(0.9),
                                Color(RMColor.brandSecondary).opacity(0.7)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 3
                    )
                    .frame(height: 20)
                
                // Screen glow effect
                ScreenArcShape()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(RMColor.brandPrimary).opacity(0.15),
                                Color.clear
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 30)
            }
            .padding(.horizontal, 40)
            
            Text("SCREEN")
                .font(.system(size: 10, weight: .heavy))
                .tracking(3.0)
                .foregroundColor(Color(RMColor.textTertiary))
        }
        .padding(.top, 10)
    }
}

// MARK: - Screen Arc Custom Shape
struct ScreenArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY),
            control: CGPoint(x: rect.midX, y: rect.minY)
        )
        return path
    }
}

// MARK: - Seat Grid Layout Section
extension SeatBookingScreen {
    private func renderSeatItem(_ seat: SeatModel) -> some View {
        let isSelected = viewModel.selectedSeatIDs.contains(seat.id)
        let isReserved = seat.status == .reserved
        
        return Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                viewModel.toggleSeat(id: seat.id)
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        isSelected ? Color(RMColor.brandPrimary) :
                        (isReserved ? Color(RMColor.surfaceBadge) : Color(RMColor.surfaceCard))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(
                                isSelected ? Color.clear :
                                (isReserved ? Color.clear : Color(RMColor.borderSubtle)),
                                lineWidth: 1
                            )
                    )
                
                if isSelected {
                    Text("\(seat.number)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                } else if isReserved {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(RMColor.textTertiary).opacity(0.4))
                }
            }
            .frame(width: 28, height: 28)
            .scaleEffect(isSelected ? 1.08 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isReserved)
    }
    
    private func renderSeatRow(_ rowSeats: [SeatModel]) -> some View {
        guard let firstSeat = rowSeats.first else { return AnyView(EmptyView()) }
        let rowLabel = firstSeat.row
        let leftSeats = rowSeats.filter { $0.number <= 4 }
        let rightSeats = rowSeats.filter { $0.number > 4 }
        
        return AnyView(
            HStack(spacing: 8) {
                // Row letter left
                Text(rowLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(RMColor.textTertiary))
                    .frame(width: 14)
                
                // Left 4 seats
                HStack(spacing: 6) {
                    ForEach(leftSeats) { seat in
                        renderSeatItem(seat)
                    }
                }
                
                // Aisle gap
                Spacer()
                    .frame(width: 14)
                
                // Right 4 seats
                HStack(spacing: 6) {
                    ForEach(rightSeats) { seat in
                        renderSeatItem(seat)
                    }
                }
                
                // Row letter right
                Text(rowLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(RMColor.textTertiary))
                    .frame(width: 14)
            }
        )
    }
    
    private func renderSeatGridSection() -> some View {
        VStack(spacing: 8) {
            ForEach(0..<viewModel.seatRows.count, id: \.self) { rowIndex in
                renderSeatRow(viewModel.seatRows[rowIndex])
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Legend Section
extension SeatBookingScreen {
    private func renderLegendItem(title: String, color: Color, strokeColor: Color? = nil, icon: String? = nil) -> some View {
        HStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(color)
                    .frame(width: 16, height: 16)
                
                if let stroke = strokeColor {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(stroke, lineWidth: 1)
                        .frame(width: 16, height: 16)
                }
                
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(Color(RMColor.textTertiary).opacity(0.6))
                }
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(RMColor.textSecondary))
        }
    }
    
    private func renderLegendSection() -> some View {
        HStack(spacing: 24) {
            renderLegendItem(
                title: "Available",
                color: Color(RMColor.surfaceCard),
                strokeColor: Color(RMColor.borderEmphasis)
            )
            renderLegendItem(
                title: "Reserved",
                color: Color(RMColor.surfaceBadge),
                icon: "xmark"
            )
            renderLegendItem(
                title: "Selected",
                color: Color(RMColor.brandPrimary)
            )
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Bottom Checkout Bar
extension SeatBookingScreen {
    private func renderBottomCheckoutBar() -> some View {
        HStack {
            // Price and Seats info
            VStack(alignment: .leading, spacing: 2) {
                Text("Total Price")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(RMColor.textTertiary))
                
                Text(viewModel.totalPriceFormatted)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color(RMColor.textPrimary))
                
                Text(viewModel.selectedSeatsFormatted)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(viewModel.canConfirm ? Color(RMColor.brandPrimary) : Color(RMColor.textTertiary))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Confirm & Pay Button
            Button(action: {
                viewModel.confirmBooking()
            }) {
                HStack(spacing: 8) {
                    Text("Confirm & Pay")
                        .font(.system(size: 15, weight: .bold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            viewModel.canConfirm ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(RMColor.brandPrimary),
                                    Color(RMColor.brandSecondary)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(RMColor.textTertiary).opacity(0.3),
                                    Color(RMColor.textTertiary).opacity(0.3)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(
                            color: viewModel.canConfirm ? Color(RMColor.brandPrimary).opacity(0.4) : Color.clear,
                            radius: 10,
                            x: 0,
                            y: 4
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!viewModel.canConfirm)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Color(RMColor.surfaceCard)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
