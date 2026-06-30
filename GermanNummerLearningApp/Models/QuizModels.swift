import SwiftUI

enum QuizType {
    case year, amount, largeNumber, phoneNumber
}

struct QuizQuestion {
    let type: QuizType
    let displayPrompt: String
    let answer1: String
    let answer2: String?
    let speechText: String
    let icon: String
    let themeColor: Color
}

enum AppViewMode {
    case home
    case practice
    case quiz
}

struct LargeNumberContext {
    let number: Int64
    let unitPosition: UnitPosition
    let uiTemplate: (String) -> String
    let speechTemplate: (String) -> String
    
    enum UnitPosition {
        case thousand
        case million
    }
}
