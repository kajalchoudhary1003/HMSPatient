//
//  Extensions.swift
//  HMSAdmin
//
//  Created by Ansh Kalra on 08/07/24.
//

import SwiftUI
import Foundation

// Initialize Color from hex string
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
    static let customBackground = Color("BackgroundColor")
       static let customPrimary = Color("AccentColor")
       static let customPremium = Color("PremiumColor")
}

extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self.frame(maxHeight: .infinity, alignment: alignment)
    }
}

func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
    return Calendar.current.isDate(date1, inSameDayAs: date2)
}


extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

extension Date {
    /// Formats the date to a string with a specified format
    func formattedString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Checks whether the date is today
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    /// Fetches the week containing the current date
    func fetchWeek() -> [Date.WeekDay] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        
        var days: [Date.WeekDay] = []
        (0..<7).forEach { index in
            if let date = calendar.date(byAdding: .day, value: index, to: startOfWeek) {
                days.append(Date.WeekDay(date: date))
            }
        }
        return days
    }
}

// MARK: - WeekDay Struct

extension Date {
    /// Structure to represent a day in a week
    struct WeekDay: Identifiable, Hashable {
        var id = UUID()
        var date: Date
    }
}

extension Date {
    func format(_ dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension Doctor {
    func generateTimeSlots() -> [TimeSlot] {
        let regularIntervalMinutes = 15
        let premiumIntervalMinutes = 30
        var currentTime = roundToNearestHour(self.starts)
        var slots: [TimeSlot] = []
        
        while currentTime < self.ends {
            let isPremium = isFirstSlotOfHour(time: currentTime)
            let intervalMinutes = isPremium ? premiumIntervalMinutes : regularIntervalMinutes
            
            let slotEndTime = min(currentTime.addingTimeInterval(TimeInterval(intervalMinutes * 60)), self.ends)
            
            let newSlot = TimeSlot(startTime: currentTime,
                                   endTime: slotEndTime,
                                   isPremium: isPremium,
                                   isAvailable: true)
            slots.append(newSlot)
            
            print("Added slot from \(currentTime.formattedString("HH:mm")) to \(slotEndTime.formattedString("HH:mm")) - Premium: \(isPremium)")
            
            currentTime = slotEndTime
            
            if currentTime >= self.ends {
                break
            }
        }
        
        print("Total slots generated: \(slots.count)")
        return slots
    }

    private func isFirstSlotOfHour(time: Date) -> Bool {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: time)
        return minute == 0
    }

    private func roundToNearestHour(_ date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? date
    }
    func matches(searchQuery: String) -> Bool {
            let query = searchQuery.lowercased()
            return name.lowercased().contains(query) ||
                   designation.title.lowercased().contains(query) ||
                   designation.relatedDiseases.contains { $0.lowercased().contains(query) }
        }
}
