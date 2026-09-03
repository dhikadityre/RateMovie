//
//  SeatBookingViewModel.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import Foundation
import Combine

public final class SeatBookingViewModel: ObservableObject {
    public let movieId: Int?
    public let movieTitle: String
    public let cinemaHall: String
    public let ticketPricePerSeat: Double
    
    @Published public var dates: [BookingDate]
    @Published public var times: [BookingTime]
    @Published public var selectedDate: BookingDate
    @Published public var selectedTime: BookingTime
    @Published public var seatRows: [[SeatModel]]
    @Published public var selectedSeatIDs: Set<String>
    
    public var onConfirmBooking: ((SeatBookingSummary) -> Void)?
    public var onDismiss: (() -> Void)?
    
    public init(
        movieId: Int? = nil,
        movieTitle: String = "Movie Title",
        cinemaHall: String = "Hall 1 - Dolby Atmos",
        ticketPricePerSeat: Double = 12.50,
        dates: [BookingDate]? = nil,
        times: [BookingTime]? = nil,
        initialSelectedSeatIDs: Set<String> = [],
        onConfirmBooking: ((SeatBookingSummary) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.movieId = movieId
        self.movieTitle = movieTitle
        self.cinemaHall = cinemaHall
        self.ticketPricePerSeat = ticketPricePerSeat
        
        let defaultDates = dates ?? Self.generateMockDates()
        let defaultTimes = times ?? Self.generateMockTimes()
        
        self.dates = defaultDates
        self.times = defaultTimes
        self.selectedDate = defaultDates.first ?? BookingDate(dayOfWeek: "TODAY", dayNumber: "03", month: "SEP", fullDateString: "03 Sep 2026")
        self.selectedTime = defaultTimes.first ?? BookingTime(timeString: "18:00")
        self.selectedSeatIDs = initialSelectedSeatIDs
        self.seatRows = Self.generateMockSeatRows(initialSelected: initialSelectedSeatIDs)
        self.onConfirmBooking = onConfirmBooking
        self.onDismiss = onDismiss
    }
    
    // MARK: - Computed Properties
    public var selectedSeats: [SeatModel] {
        seatRows.flatMap { $0 }.filter { selectedSeatIDs.contains($0.id) }
    }
    
    public var selectedSeatsFormatted: String {
        let sortedCodes = selectedSeats.map { $0.seatCode }.sorted()
        return sortedCodes.isEmpty ? "No seat selected" : sortedCodes.joined(separator: ", ")
    }
    
    public var totalPrice: Double {
        Double(selectedSeatIDs.count) * ticketPricePerSeat
    }
    
    public var totalPriceFormatted: String {
        String(format: "$%.2f", totalPrice)
    }
    
    public var canConfirm: Bool {
        !selectedSeatIDs.isEmpty
    }
    
    public var formattedShowtime: String {
        "\(selectedDate.dayNumber) \(selectedDate.month), \(selectedTime.timeString)"
    }
    
    public var bookingSummary: SeatBookingSummary {
        SeatBookingSummary(
            movieId: movieId,
            movieTitle: movieTitle,
            date: "\(selectedDate.dayNumber) \(selectedDate.month)",
            time: selectedTime.timeString,
            seats: selectedSeatsFormatted,
            selectedSeatsList: selectedSeats.map { $0.seatCode }.sorted(),
            totalPrice: totalPrice,
            cinemaHall: cinemaHall
        )
    }
    
    // MARK: - User Actions
    public func selectDate(_ date: BookingDate) {
        self.selectedDate = date
    }
    
    public func selectTime(_ time: BookingTime) {
        self.selectedTime = time
    }
    
    public func toggleSeat(row: String, number: Int) {
        let seatId = "\(row)\(number)"
        toggleSeat(id: seatId)
    }
    
    public func toggleSeat(id seatId: String) {
        for rowIndex in 0..<seatRows.count {
            for colIndex in 0..<seatRows[rowIndex].count {
                if seatRows[rowIndex][colIndex].id == seatId {
                    let currentStatus = seatRows[rowIndex][colIndex].status
                    guard currentStatus != .reserved else { return }
                    
                    if selectedSeatIDs.contains(seatId) {
                        selectedSeatIDs.remove(seatId)
                        seatRows[rowIndex][colIndex].status = .available
                    } else {
                        selectedSeatIDs.insert(seatId)
                        seatRows[rowIndex][colIndex].status = .selected
                    }
                    return
                }
            }
        }
    }
    
    public func confirmBooking() {
        guard canConfirm else { return }
        let summary = bookingSummary
        onConfirmBooking?(summary)
    }
    
    public func dismiss() {
        onDismiss?()
    }
    
    // MARK: - Mock Data Generators
    public static func generateMockDates() -> [BookingDate] {
        [
            BookingDate(dayOfWeek: "TODAY", dayNumber: "03", month: "SEP", fullDateString: "03 Sep 2026"),
            BookingDate(dayOfWeek: "THU", dayNumber: "04", month: "SEP", fullDateString: "04 Sep 2026"),
            BookingDate(dayOfWeek: "FRI", dayNumber: "05", month: "SEP", fullDateString: "05 Sep 2026"),
            BookingDate(dayOfWeek: "SAT", dayNumber: "06", month: "SEP", fullDateString: "06 Sep 2026"),
            BookingDate(dayOfWeek: "SUN", dayNumber: "07", month: "SEP", fullDateString: "07 Sep 2026"),
            BookingDate(dayOfWeek: "MON", dayNumber: "08", month: "SEP", fullDateString: "08 Sep 2026")
        ]
    }
    
    public static func generateMockTimes() -> [BookingTime] {
        [
            BookingTime(timeString: "13:00", hallName: "Hall 1 - Dolby Atmos"),
            BookingTime(timeString: "15:30", hallName: "Hall 1 - Dolby Atmos"),
            BookingTime(timeString: "18:00", hallName: "Hall 1 - Dolby Atmos"),
            BookingTime(timeString: "20:30", hallName: "Hall 1 - Dolby Atmos"),
            BookingTime(timeString: "22:45", hallName: "Hall 1 - Dolby Atmos")
        ]
    }
    
    public static func generateMockSeatRows(initialSelected: Set<String> = []) -> [[SeatModel]] {
        let rows = ["A", "B", "C", "D", "E", "F"]
        let reservedSeatIDs: Set<String> = ["A3", "A4", "B5", "C1", "C2", "D7", "D8", "E3", "F5", "F6"]
        
        return rows.map { row in
            (1...8).map { number in
                let seatId = "\(row)\(number)"
                var status: SeatStatus = .available
                if reservedSeatIDs.contains(seatId) {
                    status = .reserved
                } else if initialSelected.contains(seatId) {
                    status = .selected
                }
                return SeatModel(id: seatId, row: row, number: number, status: status, price: 12.50)
            }
        }
    }
}
