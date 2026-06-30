//
//  UIComponents.swift
//  GermanNummerLearningApp
//
//  Created by Songha Park on 6/29/26.
//

import SwiftUI


struct QuizButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}


func quizTextField(text: Binding<String>, placeholder: String) -> some View {
    TextField(placeholder, text: text)
        .multilineTextAlignment(.center)
        .frame(width: 80)
        .padding(8)
        .background(Color.black.opacity(0.05))
        .cornerRadius(8)
}
