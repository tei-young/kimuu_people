import Foundation
import SwiftUI

enum Constants {
    // MARK: - Supabase
    enum Supabase {
        // TODO: Supabase 프로젝트 생성 후 값 입력
        static let url = URL(string: "YOUR_SUPABASE_URL")!
        static let anonKey = "YOUR_SUPABASE_ANON_KEY"
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
