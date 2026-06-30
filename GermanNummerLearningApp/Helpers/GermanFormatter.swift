//
//  GermanFormatter.swift
//  GermanNummerLearningApp
//
//  Created by Songha Park on 6/29/26.
//

import Foundation

func convertChunkToGermanText(_ chunk: String) -> String {
    if chunk.hasPrefix("0") && chunk.count > 1 {
        let digits = ["0":"null", "1":"eins", "2":"zwei", "3":"drei", "4":"vier", "5":"fünf", "6":"sechs", "7":"sieben", "8":"acht", "9":"neun"]
        return chunk.compactMap { digits[String($0)] }.joined(separator: " ")
    }
    
    guard let number = Int(chunk) else { return chunk }
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    formatter.locale = Locale(identifier: "de-DE")
    return formatter.string(from: NSNumber(value: number)) ?? chunk
}

func generateÖSDPhoneNumber() -> (uiDisplay: String, ttsText: String, fullNumber: String) {
    let prefix = Bool.random() ? "+43" : "+49"
    
    var bodyNumbers = "\(Int.random(in: 1...9))"
    for _ in 0..<9 { bodyNumbers += "\(Int.random(in: 0...9))" }
    
    let fullNumber = prefix + bodyNumbers
    
    var remaining = bodyNumbers
    var uiChunks: [String] = []
    var ttsChunks: [String] = ["plus", prefix == "+43" ? "vier drei" : "vier neun"]
    
    while !remaining.isEmpty {
        let chunkSize = Int.random(in: 1...3)
        let chunk = String(remaining.prefix(chunkSize))
        remaining = String(remaining.dropFirst(chunkSize))
        
        uiChunks.append(chunk)
        ttsChunks.append(convertChunkToGermanText(chunk))
    }
    
    let uiDisplay = "\(prefix) " + uiChunks.joined(separator: " ")
    let ttsText = ttsChunks.joined(separator: ", ")
    
    return (uiDisplay, ttsText, fullNumber)
}

func formatGermanAmount(_ value: Double) -> String { String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",") }

func formatGermanNumber(_ value: Int64) -> String {
    let f = NumberFormatter(); f.numberStyle = .decimal; f.groupingSeparator = "."
    return f.string(from: NSNumber(value: value)) ?? String(value)
}

func formatGermanYearToText(_ year: Int) -> String {
    if year >= 1100 && year <= 1999 {
        let f = year / 100; let s = year % 100
        return s == 0 ? "\(f) hundert" : "\(f) hundert \(s)"
    } else { return String(year) }
}


func formatGermanLargeNumberToText(_ number: Int64, unit: LargeNumberContext.UnitPosition) -> String {
    switch unit {
    case .thousand: return String(number)
    case .million:
        let m = number / 1_000_000; let r = number % 1_000_000
        let mText = m == 1 ? "eine Million" : "\(m) Millionen"
        return r > 0 ? "\(mText) \(r)" : mText
    }
}
