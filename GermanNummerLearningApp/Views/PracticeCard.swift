//
//  PracticeCard.swift
//  GermanNummerLearningApp
//
//  Created by Songha Park on 6/28/26.
//

import SwiftUI

struct PracticeCard: View {
    let title: String; let icon: String; let color: Color; let content: String
    let onNew: () -> Void; let onSpeak: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: icon).font(.title2).foregroundColor(color)
                Text(title).font(.headline).foregroundColor(.secondary)
                Spacer()
            }
            Text(content).font(.system(size: 22, weight: .semibold, design: .monospaced))
                .lineLimit(1).minimumScaleFactor(0.5).padding(.vertical, 10)
            HStack(spacing: 15) {
                Button(action: onNew) { CardButtonLabel(title: "새 데이터", systemImage: "shuffle", backgroundColor: color.opacity(0.1), foregroundColor: color) }
                Button(action: onSpeak) { CardButtonLabel(title: "듣기", systemImage: "play.fill", backgroundColor: color, foregroundColor: .white) }
            }
        }
        .padding().background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}


struct CardButtonLabel: View {
    let title: String
    let systemImage: String
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(10)
    }
}

