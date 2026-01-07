import Foundation
import SwiftUI

enum Constants {
    // MARK: - Supabase
    enum Supabase {
        static let url = URL(string: "https://hwrcbitynfrjxmukwxya.supabase.co")!
        static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh3cmNiaXR5bmZyanhtdWt3eHlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3NDQ5MzksImV4cCI6MjA4MzMyMDkzOX0.ss2u_0eKzMMm8zON_HdWM6R47jzwBmg-skz58ok_QR0"
    }
    
    // MARK: - Calendar
    enum Calendar {
        static let defaultScrollHour = 9
        static let minTimeUnit = 10
        static let maxStaffsPerPage = 4
    }
    
    // MARK: - Color Palette
    static let colorPalette: [String] = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4",
        "#FFEAA7", "#DDA0DD", "#98D8C8", "#F7DC6F",
        "#BB8FCE", "#85C1E9", "#F8B500", "#82E0AA"
    ]
    
    // MARK: - Default Treatment Types
    static let defaultTreatmentTypes: [String] = [
        "눈썹문신", "입술문신", "애교살"
    ]
}

enum TimeScale: Int, CaseIterable {
    case hour = 60
    case halfHour = 30
    case tenMin = 10
    
    var displayName: String {
        switch self {
        case .hour: return "1시간"
        case .halfHour: return "30분"
        case .tenMin: return "10분"
        }
    }
    
    var rowHeight: CGFloat {
        switch self {
        case .hour: return 60
        case .halfHour: return 40
        case .tenMin: return 30
        }
    }
    
    func zoomIn() -> TimeScale {
        switch self {
        case .hour: return .halfHour
        case .halfHour: return .tenMin
        case .tenMin: return .tenMin
        }
    }
    
    func zoomOut() -> TimeScale {
        switch self {
        case .hour: return .hour
        case .halfHour: return .hour
        case .tenMin: return .halfHour
        }
    }
}
