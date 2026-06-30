import SwiftUI
import AVFoundation

// MARK: - Data Models

    //quizModels


// MARK: - Main View

struct ContentView: View {
    @State private var currentMode: AppViewMode = .home
    
    // State states for Practice Mode
    @State private var startYear = 0
    @State private var endYear = 0
    @State private var amount: Double = 0.0
    @State private var largeNumber: Int64 = 0
    @State private var currentContext: LargeNumberContext? = nil
    @State private var practicePhoneData: (uiDisplay: String, ttsText: String, fullNumber: String)? = nil
    
    // State states for Quiz Mode
    @State private var currentQuiz: QuizQuestion? = nil
    @State private var userInput1 = ""
    @State private var userInput2 = ""
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var quizCount = 0
    @State private var currentPhoneData: (uiDisplay: String, ttsText: String, fullNumber: String)? = nil
    
    let synthesizer = AVSpeechSynthesizer()
    
    // Context datasets for high-magnitude numbers
    private let largeNumberContexts: [LargeNumberContext] = [
        LargeNumberContext(number: 13_000_000, unitPosition: .million, uiTemplate: { "\($0) Euro" }, speechTemplate: { "\($0) Euro" }),
        LargeNumberContext(number: 19_000, unitPosition: .thousand, uiTemplate: { "\($0) Arbeitsplätze" }, speechTemplate: { "\($0) Arbeitsplätze" }),
        LargeNumberContext(number: 15_000, unitPosition: .thousand, uiTemplate: { "\($0) Befragte" }, speechTemplate: { "\($0) Befragte" }),
        LargeNumberContext(number: 2_500_000, unitPosition: .million, uiTemplate: { "\($0) Menschen" }, speechTemplate: { "\($0) Menschen" }),
        LargeNumberContext(number: 850_000, unitPosition: .thousand, uiTemplate: { "\($0) Autos" }, speechTemplate: { "\($0) Autos" })
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.05).ignoresSafeArea()
                
                switch currentMode {
                case .home:
                    homeMenuView
                case .practice:
                    practiceView
                case .quiz:
                    quizView
                }
            }
            .navigationTitle(currentMode == .home ? "독일어 숫자 마스터" : currentMode == .practice ? "숫자 연습하기" : "종합 테스트")
            .toolbar {
                if currentMode != .home {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: { currentMode = .home }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("홈")
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
            }
        }
        .onAppear {
            randomizeYears()
            randomizeAmount()
            randomizeLargeNumber()
            randomizePhoneNumber()
        }
    }
    
    // MARK: - Subviews: Dashboard
    
    var homeMenuView: some View {
        VStack(spacing: 35) {
            Spacer()
            
            VStack(spacing: 12) {
                Text("🇩🇪")
                    .font(.system(size: 65))
                Text("Willkommen!")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                Text("귀로 듣고 직접 채우는 독일어 숫자 훈련")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
            
            VStack(spacing: 20) {
                Button(action: { currentMode = .practice }) {
                    HStack {
                        Image(systemName: "book.pages.fill")
                            .font(.title2)
                        Text("연습하기 (Übung)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Button(action: {
                    startNewQuiz()
                    currentMode = .quiz
                }) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                        Text("퀴즈시작 (Test)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Subviews: Practice Mode
    
    var practiceView: some View {
        ScrollView {
            VStack(spacing: 20) {
                PracticeCard(title: "연도 읽기 (Jahr)", icon: "calendar", color: .blue, content: "von \(startYear) bis zum \(endYear)", onNew: randomizeYears, onSpeak: speakYears)
                
                PracticeCard(title: "금액 읽기 (Betrag)", icon: "eurosign.circle", color: .green, content: "Es macht \(formatGermanAmount(amount)) Euro", onNew: randomizeAmount, onSpeak: speakAmount)
                
                PracticeCard(title: "큰 수 읽기 (Große Zahlen)", icon: "chart.bar.fill", color: .purple, content: currentContext?.uiTemplate(formatGermanNumber(largeNumber)) ?? "", onNew: randomizeLargeNumber, onSpeak: speakLargeNumber)
                
                PracticeCard(title: "전화번호 듣기 (Telefonnummer)", icon: "phone.circle.fill", color: .orange, content: practicePhoneData?.uiDisplay ?? "", onNew: randomizePhoneNumber, onSpeak: speakPhoneNumber)
                        
            }
            .padding()
        }
    }

    // MARK: - Subviews: Quiz Mode
    
    var quizView: some View {
        VStack(spacing: 30) {
            ProgressView(value: Double(quizCount % 10), total: 10)
                .padding(.horizontal)

            if let quiz = currentQuiz {
                VStack(spacing: 25) {
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "quiz.icon")
                            Text(quiz.type == .year ? "연도 퀴즈" : quiz.type == .amount ? "금액 퀴즈" : "통계 퀴즈")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        Text("A 문장을 듣고 빈칸을 채우세요")
                            .font(.subheadline)
                        
                        Button(action: { speakText(quiz.speechText) }) {
                            ZStack {
                                Circle().fill(quiz.themeColor.opacity(0.1)).frame(width: 80, height: 80)
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title).foregroundColor(quiz.themeColor)
                            }
                        }
                        .padding(.vertical, 10)

                        HStack(spacing: 10) {
                            if quiz.type == .year {
                                Text("von")
                                quizTextField(text: $userInput1, placeholder: "연도")
                                Text("bis zum")
                                quizTextField(text: $userInput2, placeholder: "연도")
                            } else if quiz.type == .amount {
                                Text("Es macht")
                                quizTextField(text: $userInput1, placeholder: "Euro")
                                Text("Euro")
                                quizTextField(text: $userInput2, placeholder: "Cent")
                            } else if quiz.type == .phoneNumber {
                                    // 👈 전화번호 전용 UI 추가!
                                    VStack(alignment: .leading, spacing: 10) {
                                        quizTextField(text: $userInput1, placeholder: "+로 시작하는 전체 번호 입력")
                                            .frame(width: 250) // 전화번호는 기니까 텍스트필드를 넓게 줍니다.
                                        
                                        Text("힌트: \(quiz.displayPrompt)") // 끊어 읽기 덩어리를 힌트로 보여줌
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                            } else {
                                quizTextField(text: $userInput1, placeholder: "숫자 입력")
                                Text(quiz.displayPrompt.replacingOccurrences(of: "...", with: ""))
                            }
                        }
                        .font(.system(size: 18, weight: .bold))
                    }
                    .padding(25)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    
                    if showResult {
                        Text(isCorrect ? "Richtig! (정답입니다)" : "Falsch! (오답입니다)")
                            .font(.title3).fontWeight(.bold)
                            .foregroundColor(isCorrect ? .green : .red)
                    }

                    HStack(spacing: 20) {
                        Button("정답 확인") {
                            checkAnswer()
                        }
                        .buttonStyle(QuizButtonStyle(color: .orange))
                        
                        Button("다음 문제") {
                            startNewQuiz()
                        }
                        .buttonStyle(QuizButtonStyle(color: .green))
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
    
    // MARK: - Business Logic: Quiz Engine
    
    func startNewQuiz() {
        userInput1 = ""
        userInput2 = ""
        showResult = false
        quizCount += 1
        
        let types: [QuizType] = [.year, .amount, .largeNumber, .phoneNumber]
        let randomType = types.randomElement()!
        
        switch randomType {
        case .year:
            let s = Int.random(in: 1100...2099)
            let e = Int.random(in: s...2099)
            currentQuiz = QuizQuestion(type: .year, displayPrompt: "von ... bis zum ...", answer1: "\(s)", answer2: "\(e)", speechText: "von \(formatGermanYearToText(s)) bis zum \(formatGermanYearToText(e))", icon: "calendar", themeColor: .blue)
        case .amount:
            let val = (Double.random(in: 1...999.99) * 100).rounded() / 100
            let eur = Int(val)
            let cnt = Int(round((val - Double(eur)) * 100))
            currentQuiz = QuizQuestion(type: .amount, displayPrompt: "Es macht ... Euro ...", answer1: "\(eur)", answer2: cnt > 0 ? "\(cnt)" : "0", speechText: "Es macht \(eur) Euro \(cnt > 0 ? "\(cnt)" : "")", icon: "eurosign.circle", themeColor: .green)
        case .largeNumber:
            let ctx = largeNumberContexts.randomElement()!
            let num: Int64
            if ctx.unitPosition == .million {
                num = Int64.random(in: 1...25) * 1_000_000 + Int64.random(in: 100...999) * 1_000
            } else {
                num = Int64.random(in: 10...99) * 1_000
            }
            currentQuiz = QuizQuestion(type: .largeNumber, displayPrompt: ctx.uiTemplate("..."), answer1: "\(num)", answer2: nil, speechText: ctx.speechTemplate(formatGermanLargeNumberToText(num, unit: ctx.unitPosition)), icon: "chart.bar.fill", themeColor: .purple)
            
        case .phoneNumber:
            let phoneData = generateÖSDPhoneNumber()
            self.currentPhoneData = phoneData // 👈 방금 만든 State 변수에 데이터 보관!
            
            currentQuiz = QuizQuestion(
                type: .phoneNumber,
                displayPrompt: phoneData.uiDisplay,
                answer1: phoneData.fullNumber,
                answer2: nil,
                speechText: phoneData.ttsText,
                icon: "phone.circle.fill",
                themeColor: .orange
            )
        }
        
        
        
        
        // Auto-play TTS upon initialization
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let txt = currentQuiz?.speechText { speakText(txt) }
        }
    }
    
    func checkAnswer() {
        guard let quiz = currentQuiz else { return }
        
        // Strip grouping separators for validation comparison
        let cleanInput1 = userInput1.replacingOccurrences(of: ".", with: "")
                                        .replacingOccurrences(of: ",", with: "")
                                        .replacingOccurrences(of: " ", with: "") // 👈 추가
            let cleanInput2 = userInput2.replacingOccurrences(of: ".", with: "")
                                        .replacingOccurrences(of: ",", with: "")
                                        .replacingOccurrences(of: " ", with: "") // 👈 추가
            
            if quiz.type == .amount {
                isCorrect = (cleanInput1 == quiz.answer1 && (cleanInput2 == quiz.answer2 || (quiz.answer2 == "0" && cleanInput2 == "")))
            } else {
                isCorrect = (cleanInput1 == quiz.answer1 && (quiz.answer2 == nil || cleanInput2 == quiz.answer2))
            }
        
        showResult = true
    }

    // MARK: - Core Helpers & Formatters

        func speakText(_ text: String) {
            if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
            let utterance = AVSpeechUtterance(string: text)
             utterance.voice = AVSpeechSynthesisVoice(language: "de-DE")
            utterance.rate = 0.45
            synthesizer.speak(utterance)
        }
        
        func randomizeYears() { startYear = Int.random(in: 1000...2099); endYear = Int.random(in: startYear...2099) }
        func randomizeAmount() { amount = (Double.random(in: 1...999.99) * 100).rounded() / 100 }
        
        func randomizeLargeNumber() {
            if let randomCtx = largeNumberContexts.randomElement() {
                currentContext = randomCtx
                if randomCtx.unitPosition == .million {
                    largeNumber = Int64.random(in: 1...25) * 1_000_000 + Int64.random(in: 100...999) * 1_000
                } else {
                    largeNumber = Int64.random(in: 10...99) * 1_000
                }
            }
        } // 👈 아까 누락되었던 randomizeLargeNumber의 닫는 괄호 추가!

        func randomizePhoneNumber() {
            practicePhoneData = generateÖSDPhoneNumber()
        }
        
        func speakYears() { speakText("von \(formatGermanYearToText(startYear)) bis zum \(formatGermanYearToText(endYear))") }
        func speakAmount() {
            let e = Int(amount); let c = Int(round((amount - Double(e)) * 100))
            speakText("Es macht \(e) Euro \(c > 0 ? "\(c)" : "")")
        }
        func speakLargeNumber() {
            guard let ctx = currentContext else { return }
            speakText(ctx.speechTemplate(formatGermanLargeNumberToText(largeNumber, unit: ctx.unitPosition)))
        }
        func speakPhoneNumber() {
            guard let data = practicePhoneData else { return }
            speakText(data.ttsText)
        }
        
    } // 👈 ContentView 클래스를 닫아주는 최종 괄호!

    // MARK: - UI Components & Custom Modifiers

    #Preview { ContentView() }
