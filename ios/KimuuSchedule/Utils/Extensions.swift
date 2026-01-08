import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }
    
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    var hourAndMinute: (hour: Int, minute: Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: self)
        return (components.hour ?? 0, components.minute ?? 0)
    }
    
    func setting(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: self) ?? self
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension String {
    var formattedPhoneNumber: String {
        let digits = self.filter { $0.isNumber }
        
        guard !digits.isEmpty else { return "" }
        
        var result = ""
        let digitArray = Array(digits)
        
        for (index, digit) in digitArray.enumerated() {
            if index == 3 || index == 7 {
                result += "-"
            }
            if index < 11 {
                result += String(digit)
            }
        }
        
        return result
    }
    
    var digitsOnly: String {
        self.filter { $0.isNumber }
    }
}
