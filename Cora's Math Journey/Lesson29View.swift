import SwiftUI

// MARK: - Lesson 29 View
struct Lesson29View: View {
    @Binding var totalPoints: Int
    @Binding var lessonCompleted: Bool
    var onComplete: ((Int) -> Void)? = nil
    @Environment(\.dismiss) var dismiss
    
    @State private var currentScreen = "warmup" // "warmup" or "main"
    @State private var currentQuestion = 0
    @State private var userAnswer = ""
    @State private var frogPosition = 0
    @State private var showFeedback = false
    @State private var isCorrect = false
    @State private var warmupPoints = 0
    @State private var frogIsJumping = false
    @State private var frogRotation = 0.0
    
    // Main lesson states
    @State private var mainLessonPoints = 0
    @State private var currentCustomer = 0
    @State private var draggedBaskets = 0
    @State private var draggedSingles = 0
    @State private var incorrectCustomers: [Int] = []
    
    // Warm-up questions
    let warmupQuestions = [
        (prompt: "Saturday", answer: "sunday", type: "day"),
        (prompt: "3", answer: "4", type: "number"),
        (prompt: "C", answer: "d", type: "letter"),
        (prompt: "Tuesday", answer: "wednesday", type: "day"),
        (prompt: "7", answer: "8", type: "number"),
        (prompt: "M", answer: "n", type: "letter"),
        (prompt: "Thursday", answer: "friday", type: "day"),
        (prompt: "19", answer: "20", type: "number"),
        (prompt: "R", answer: "s", type: "letter")
    ]
    
    // Customer orders
    let customerOrders = [
        (name: "Mrs. Smith", apples: 46),
        (name: "Mr. Johnson", apples: 23),
        (name: "Ms. Davis", apples: 35),
        (name: "Mr. Brown", apples: 58),
        (name: "Mrs. Wilson", apples: 17),
        (name: "Ms. Taylor", apples: 61),
        (name: "Mr. Anderson", apples: 29),
        (name: "Mrs. Thomas", apples: 74)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    // Reset states before dismissing
                    currentQuestion = 0
                    frogPosition = 0
                    userAnswer = ""
                    showFeedback = false
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back to Menu")
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Lesson 29: Tens and Ones")
                        .font(.headline)
                    if currentScreen == "warmup" {
                        Text("Warm-Up Points: \(warmupPoints)/10")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Lesson Points: \(mainLessonPoints)/40")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            
            // Main Content
            if currentScreen == "warmup" {
                // Warmup Game Content (your existing leap frog game)
                if currentQuestion < warmupQuestions.count {
                    WarmupGameView(
                        currentQuestion: currentQuestion,
                        warmupQuestions: warmupQuestions,
                        userAnswer: $userAnswer,
                        frogPosition: $frogPosition,
                        showFeedback: $showFeedback,
                        isCorrect: $isCorrect,
                        warmupPoints: $warmupPoints,
                        frogIsJumping: $frogIsJumping,
                        frogRotation: $frogRotation,
                        checkAnswer: checkAnswer,
                        performHop: performHop
                    )
                } else {
                    WarmupCompleteView(
                        points: warmupPoints,
                        onContinue: {
                            currentScreen = "main"
                        }
                    )
                }
            } else {
                // Main Lesson - Apple Store
                AppleStoreView(
                    customerOrders: customerOrders,
                    currentCustomer: $currentCustomer,
                    draggedBaskets: $draggedBaskets,
                    draggedSingles: $draggedSingles,
                    mainLessonPoints: $mainLessonPoints,
                    incorrectCustomers: $incorrectCustomers,
                    onComplete: {
                        totalPoints += warmupPoints + mainLessonPoints
                        lessonCompleted = true
                        dismiss()
                    }
                )
            }
            
            Spacer()
        }
        .frame(minWidth: 1400, minHeight: 900)
        .background(Color.blue.opacity(0.05))
    }
    
    func checkAnswer() {
        let correct = userAnswer.lowercased().trimmingCharacters(in: .whitespaces) == warmupQuestions[currentQuestion].answer
        
        withAnimation {
            isCorrect = correct
            showFeedback = true
        }
        
        if correct {
            performHop()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                currentQuestion += 1
                warmupPoints += 1
                userAnswer = ""
                showFeedback = false
                
                if currentQuestion >= warmupQuestions.count {
                    warmupPoints += 1
                    frogPosition = 19
                }
            }
        }
    }
    
    func performHop() {
        withAnimation(.easeOut(duration: 0.3)) {
            frogIsJumping = true
            frogRotation = -20
            frogPosition += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 0.3)) {
                frogIsJumping = false
                frogRotation = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.3)) {
                frogIsJumping = true
                frogRotation = -20
                frogPosition += 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.3)) {
                    frogIsJumping = false
                    frogRotation = 0
                }
            }
        }
    }
}

// MARK: - Apple Store View
struct AppleStoreView: View {
    let customerOrders: [(name: String, apples: Int)]
    @Binding var currentCustomer: Int
    @Binding var draggedBaskets: Int
    @Binding var draggedSingles: Int
    @Binding var mainLessonPoints: Int
    @Binding var incorrectCustomers: [Int]
    let onComplete: () -> Void
    
    @State private var showResult = false
    @State private var resultMessage = ""
    @State private var isResultCorrect = false
    @State private var availableBaskets = 8
    @State private var availableApples = 9
    @State private var showAnimation = false
    
    var currentOrder: (name: String, apples: Int)? {
        let allCustomers = customerOrders + incorrectCustomers.map { customerOrders[$0] }
        guard currentCustomer < allCustomers.count else { return nil }
        return allCustomers[currentCustomer]
    }
    
    var body: some View {
        if let order = currentOrder {
            VStack(spacing: 20) {  // Reduced from 30
                // Title
                Text("🍎 Cora's Apple Store")
                    .font(.title2)  // Reduced from .largeTitle
                    .fontWeight(.bold)
                
                // Customer Request - make more compact
                HStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))  // Reduced from 50
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(order.name)
                            .font(.title3)  // Reduced from .title2
                        
                        Text("I would like \(order.apples) apples please!")
                            .font(.body)  // Reduced from .title3
                            .padding(8)  // Reduced padding
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(radius: 2)
                            )
                    }
                }
                .padding(.horizontal)
                
                // Apple Storage Area - side by side to save vertical space
                HStack(spacing: 30) {
                    // Baskets
                    VStack {
                        Text("Baskets (10 each)")
                            .font(.subheadline)
                        Text("\(availableBaskets) available")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        LazyVGrid(columns: [GridItem(.fixed(70)), GridItem(.fixed(70))], spacing: 10) {
                            ForEach(0..<availableBaskets, id: \.self) { _ in
                                BasketView()
                                    .scaleEffect(0.9)
                                    .onTapGesture {
                                        if availableBaskets > 0 {
                                            withAnimation(.spring()) {
                                                availableBaskets -= 1
                                                draggedBaskets += 1
                                            }
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Customer's Order Box in the middle
                    VStack {
                        Text("Customer's Order")
                            .font(.subheadline)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                                .foregroundColor(.blue)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.05))
                                )
                            
                            if draggedBaskets == 0 && draggedSingles == 0 {
                                Text("Click items to add")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            } else {
                                VStack {
                                    // Show baskets
                                    if draggedBaskets > 0 {
                                        HStack {
                                            ForEach(0..<min(draggedBaskets, 8), id: \.self) { _ in
                                                BasketView()
                                                    .scaleEffect(0.6)
                                                    .onTapGesture {
                                                        withAnimation(.spring()) {
                                                            draggedBaskets -= 1
                                                            availableBaskets += 1
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                    
                                    // Show apples
                                    if draggedSingles > 0 {
                                        HStack {
                                            ForEach(0..<min(draggedSingles, 9), id: \.self) { _ in
                                                SingleAppleView()
                                                    .scaleEffect(0.6)
                                                    .onTapGesture {
                                                        withAnimation(.spring()) {
                                                            draggedSingles -= 1
                                                            availableApples += 1
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                                .padding(5)
                            }
                        }
                        .frame(width: 300, height: 100)
                        
                        Text("\(draggedBaskets * 10 + draggedSingles) total")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    // Single Apples
                    VStack {
                        Text("Single Apples")
                            .font(.subheadline)
                        Text("\(availableApples) available")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        LazyVGrid(columns: [GridItem(.fixed(45)), GridItem(.fixed(45)), GridItem(.fixed(45))], spacing: 8) {
                            ForEach(0..<availableApples, id: \.self) { _ in
                                SingleAppleView()
                                    .scaleEffect(0.9)
                                    .onTapGesture {
                                        if availableApples > 0 {
                                            withAnimation(.spring()) {
                                                availableApples -= 1
                                                draggedSingles += 1
                                            }
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons and Feedback in same row
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation {
                            availableBaskets += draggedBaskets
                            availableApples += draggedSingles
                            draggedBaskets = 0
                            draggedSingles = 0
                        }
                    }) {
                        Text("Clear")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: checkAppleOrder) {
                        Text("Submit")
                            .padding(.horizontal, 30)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    if showResult {
                        HStack {
                            Image(systemName: isResultCorrect ? "checkmark.circle.fill" : "x.circle.fill")
                                .font(.title2)
                                .foregroundColor(isResultCorrect ? .green : .red)
                            
                            Text(isResultCorrect ? "Correct!" : "Try again")
                                .font(.subheadline)
                                .foregroundColor(isResultCorrect ? .green : .orange)
                        }
                        .transition(.scale)
                    }
                }
                .padding()
            }
        } else {
            // Move to Right Angle Builder
            RightAngleBuilderView(
                mainLessonPoints: $mainLessonPoints,
                onComplete: onComplete
            )
        }
    }
    
    func checkAppleOrder() {
        guard let order = currentOrder else { return }
        
        let totalApples = draggedBaskets * 10 + draggedSingles
        let correctTens = order.apples / 10
        let correctOnes = order.apples % 10
        
        if totalApples == order.apples && draggedBaskets == correctTens && draggedSingles == correctOnes {
            // Correct!
            isResultCorrect = true
            resultMessage = "Perfect! You gave exactly \(order.apples) apples!\n\(correctTens) baskets + \(correctOnes) singles = \(order.apples)"
            mainLessonPoints += 5
            
            withAnimation(.spring()) {
                showResult = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    currentCustomer += 1
                    availableBaskets = 8
                    availableApples = 9
                    draggedBaskets = 0
                    draggedSingles = 0
                    showResult = false
                }
            }
        } else {
            // Incorrect
            isResultCorrect = false
            if totalApples != order.apples {
                resultMessage = "That's \(totalApples) apples, but they asked for \(order.apples).\nTry again!"
            } else {
                resultMessage = "Right total, but use \(correctTens) baskets and \(correctOnes) singles!\nRemember: Use tens when you can!"
            }
            
            if !incorrectCustomers.contains(currentCustomer) && currentCustomer < customerOrders.count {
                incorrectCustomers.append(currentCustomer)
            }
            
            withAnimation(.spring()) {
                showResult = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showResult = false
                }
            }
        }
    }
}

// MARK: - Draggable Basket
struct DraggableBasket: View {
    @State private var isDragging = false
    
    var body: some View {
        BasketView()
            .scaleEffect(isDragging ? 1.2 : 1.0)
            .opacity(isDragging ? 0.6 : 1.0)
            .onDrag {
                isDragging = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isDragging = false
                }
                return NSItemProvider(object: "basket" as NSString)
            }
            .animation(.easeInOut(duration: 0.2), value: isDragging)
    }
}

// MARK: - Draggable Apple
struct DraggableApple: View {
    @State private var isDragging = false
    
    var body: some View {
        SingleAppleView()
            .scaleEffect(isDragging ? 1.2 : 1.0)
            .opacity(isDragging ? 0.6 : 1.0)
            .onDrag {
                isDragging = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isDragging = false
                }
                return NSItemProvider(object: "apple" as NSString)
            }
            .animation(.easeInOut(duration: 0.2), value: isDragging)
    }
}

// MARK: - Basket View
struct BasketView: View {
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "basket.fill")
                .font(.system(size: 40))
                .foregroundColor(.brown)
            Text("10")
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Single Apple View
struct SingleAppleView: View {
    var body: some View {
        Text("🍎")
            .font(.system(size: 35))
    }
}

// MARK: - Lesson Complete View
struct LessonCompleteView: View {
    let totalPoints: Int
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🎉 Lesson Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You've mastered Tens and Ones!")
                .font(.title2)
            
            Text("Total Lesson Points: \(totalPoints + 10)/50")
                .font(.title2)
                .foregroundColor(.green)
            
            Button(action: onComplete) {
                Text("Return to Menu")
                    .font(.title3)
                    .padding()
                    .frame(width: 300)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .padding(60)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 15)
        )
    }
}


// MARK: - Right Angle House Builder View
struct RightAngleBuilderView: View {
    @Binding var mainLessonPoints: Int
    let onComplete: () -> Void
    
    @State private var currentAngle = 0
    @State private var rotatingLineAngle: Double = 45  // Starting angle
    @State private var showFeedback = false
    @State private var isCorrect = false
    @State private var houseParts = 0  // How many parts of house are built
    @State private var feedbackMessage = ""
    
    // Different starting angles for each of the 5 challenges (all divisible by 5)
    let startingAngles = [45, 135, 30, 120, 60]
    let housePieces = ["Foundation", "Left Wall", "Right Wall", "Roof", "Door"]
    
    var body: some View {
        if currentAngle < 5 {
            VStack(spacing: 20) {
                // Title
                Text("🏠 Build a House with Right Angles")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Use ← → arrow keys to make a right angle (90°)")
                    .font(.title3)
                    .foregroundColor(.gray)
                
                HStack(spacing: 50) {
                    // Angle Builder Area
                    VStack {
                        Text("Make a Right Angle")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Current Angle: \(Int(rotatingLineAngle))°")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        // Angle Display
                        ZStack {
                            // Background circle guide
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 2)
                                .frame(width: 250, height: 250)
                            
                            // Fixed horizontal wood piece
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.brown.opacity(0.8),
                                            Color.brown,
                                            Color.brown.opacity(0.6)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 120, height: 12)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.brown.opacity(0.3), lineWidth: 0.5)
                                )
                                .position(x: 185, y: 125)  // Position to the right of center
                            
                            // Rotating wood piece
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.orange.opacity(0.8),
                                            Color.orange,
                                            Color.orange.opacity(0.6)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 120, height: 12)
                                .overlay(
                                    Rectangle()
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 0.5)
                                )
                                .offset(x: -60)  // Offset so rotation point is at the right edge
                                .rotationEffect(.degrees(-rotatingLineAngle))  // Negative for correct direction
                                .position(x: 125, y: 125)  // Center point where pieces meet
                                .animation(.easeInOut(duration: 0.15), value: rotatingLineAngle)
                            
                            // Angle indicator arc
                            Path { path in
                                let center = CGPoint(x: 125, y: 125)
                                let radius: CGFloat = 40
                                path.move(to: center)
                                path.addArc(
                                    center: center,
                                    radius: radius,
                                    startAngle: .degrees(-rotatingLineAngle),
                                    endAngle: .degrees(0),
                                    clockwise: rotatingLineAngle > 0
                                )
                                path.closeSubpath()
                            }
                            .fill(
                                rotatingLineAngle == 90 ? Color.green.opacity(0.3) :
                                abs(rotatingLineAngle - 90) < 10 ? Color.yellow.opacity(0.3) :
                                Color.blue.opacity(0.3)
                            )
                            
                            // Angle text
                            if rotatingLineAngle == 90 {
                                Text("90°")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.green)
                                    .position(x: 125, y: 80)
                            }
                            
                            // Center connection point (nail/screw)
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                .position(x: 125, y: 125)
                        }
                        .frame(width: 250, height: 250)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(15)
                        .onAppear {
                            setupKeyboardHandling()
                            // Set initial angle
                            rotatingLineAngle = Double(startingAngles[0])
                        }
                        
                        // Instructions
                        HStack(spacing: 30) {
                            VStack {
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                Text("Rotate Left")
                                    .font(.caption)
                            }
                            VStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                Text("Rotate Right")
                                    .font(.caption)
                            }
                        }
                        .padding()
                        
                        // Submit Button
                        Button(action: checkAngle) {
                            Text("Submit Angle")
                                .font(.title3)
                                .padding()
                                .frame(width: 200)
                                .background(rotatingLineAngle == 90 ? Color.green : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        // Feedback
                        if showFeedback {
                            Text(feedbackMessage)
                                .font(.title3)
                                .foregroundColor(isCorrect ? .green : .orange)
                                .fontWeight(.semibold)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .shadow(radius: 3)
                                )
                        }
                    }
                    
                    // House Building Area
                    VStack {
                        Text("Your House")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Building: \(housePieces[min(houseParts, 4)])")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        ZStack {
                            HouseView(partsCompleted: houseParts)
                                .frame(width: 300, height: 300)
                        }
                        .frame(width: 350, height: 350)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(15)
                        
                        Text("Parts Built: \(houseParts)/5")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
        } else {
            // Completed all angles
            AngleCompleteView(
                points: 50,  // 8 points per angle
                onComplete: {
                    mainLessonPoints += 50
                    onComplete()
                }
            )
        }
    }
    
    func setupKeyboardHandling() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            switch event.keyCode {
            case 123: // Left arrow
                withAnimation {
                    rotatingLineAngle -= 5  // Move by 5 degrees
                    if rotatingLineAngle < 0 {
                        rotatingLineAngle += 360
                    }
                }
                return nil
            case 124: // Right arrow
                withAnimation {
                    rotatingLineAngle += 5  // Move by 5 degrees
                    if rotatingLineAngle >= 360 {
                        rotatingLineAngle -= 360
                    }
                }
                return nil
            default:
                return event
            }
        }
    }
    
    func checkAngle() {
        if rotatingLineAngle == 90 {
            isCorrect = true
            feedbackMessage = "Perfect! That's exactly 90°!"
            houseParts += 1
            mainLessonPoints += 10
            
            withAnimation {
                showFeedback = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                currentAngle += 1
                if currentAngle < startingAngles.count {
                    rotatingLineAngle = Double(startingAngles[currentAngle])
                }
                showFeedback = false
            }
        } else {
            isCorrect = false
            let difference = Int(abs(rotatingLineAngle - 90))
            if difference < 10 {
                feedbackMessage = "Very close! You're only \(difference)° away from 90°"
            } else {
                feedbackMessage = "Not quite. A right angle is exactly 90°. You have \(Int(rotatingLineAngle))°"
            }
            
            withAnimation {
                showFeedback = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showFeedback = false
            }
        }
    }
}
// MARK: - Angle Arc
struct AngleArc: Shape {
    let angle: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(angle),
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - House View
struct HouseView: View {
    let partsCompleted: Int
    
    var body: some View {
        ZStack {
            // Foundation (Part 1)
            if partsCompleted >= 1 {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 200, height: 20)
                    .position(x: 150, y: 250)
            }
            
            // Left Wall (Part 2)
            if partsCompleted >= 2 {
                Rectangle()
                    .fill(Color.brown)
                    .frame(width: 15, height: 150)
                    .position(x: 57, y: 175)
            }
            
            // Right Wall (Part 3)
            if partsCompleted >= 3 {
                Rectangle()
                    .fill(Color.brown)
                    .frame(width: 15, height: 150)
                    .position(x: 243, y: 175)
            }
            
            // Roof (Part 4)
            if partsCompleted >= 4 {
                Triangle()
                    .fill(Color.red)
                    .frame(width: 200, height: 80)
                    .position(x: 150, y: 80)
            }
            
            // Door (Part 5)
            if partsCompleted >= 5 {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 40, height: 60)
                    .position(x: 150, y: 215)
            }
        }
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Angle Complete View
struct AngleCompleteView: View {
    let points: Int
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🏠 House Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("You've mastered right angles!")
                .font(.title2)
            
            HouseView(partsCompleted: 5)
                .frame(width: 300, height: 300)
            
            Text("You earned \(points) points!")
                .font(.title2)
                .foregroundColor(.green)
            
            Button(action: onComplete) {
                Text("Finish Lesson")
                    .font(.title3)
                    .padding()
                    .frame(width: 300)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .padding(60)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 15)
        )
    }
}
// MARK: - Frog View
struct FrogView: View {
    let isJumping: Bool
    
    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(Color.green)
                .frame(width: 50, height: 45)
                .overlay(
                    Ellipse()
                        .fill(Color.green.opacity(0.7))
                        .frame(width: 35, height: 30)
                        .offset(y: 5)
                )
            
            // Head
            Circle()
                .fill(Color.green)
                .frame(width: 40, height: 40)
                .offset(y: -15)
            
            // Eyes
            HStack(spacing: 15) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 6, height: 6)
                    )
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .fill(Color.black)
                            .frame(width: 6, height: 6)
                    )
            }
            .offset(y: -20)
            
            // Legs (visible when jumping)
            if isJumping {
                // Back legs
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.green)
                    .frame(width: 8, height: 25)
                    .rotationEffect(.degrees(-30))
                    .offset(x: -15, y: 15)
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.green)
                    .frame(width: 8, height: 25)
                    .rotationEffect(.degrees(30))
                    .offset(x: 15, y: 15)
            }
        }
        .scaleEffect(isJumping ? 1.1 : 1.0)
    }
}

// MARK: - Pond Background
struct PondBackground: View {
    var body: some View {
        ZStack {
            // Water
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.4)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.horizontal, 20)
            
            // Water ripples
            ForEach(0..<4) { i in
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                    .frame(width: CGFloat(150 + i * 80), height: CGFloat(150 + i * 80))
                    .position(x: 200, y: 180)
            }
            
            // Cattails on the sides
            Image(systemName: "leaf.fill")
                .foregroundColor(.green.opacity(0.6))
                .font(.system(size: 40))
                .rotationEffect(.degrees(-30))
                .position(x: 50, y: 100)
            
            Image(systemName: "leaf.fill")
                .foregroundColor(.green.opacity(0.6))
                .font(.system(size: 40))
                .rotationEffect(.degrees(30))
                .position(x: 1350, y: 120)
        }
    }
}

// MARK: - Lily Pad View
struct LilyPadView: View {
    let text: String
    let isCompleted: Bool
    let isBlank: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            if !isBlank && !text.isEmpty {
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                } else {
                    Text(text)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            Ellipse()
                .fill(isBlank ? Color.green.opacity(0.5) :
                      isCompleted ? Color.gray.opacity(0.5) :
                      Color.green.opacity(0.8))
                .frame(width: 65, height: 45)
                .overlay(
                    Ellipse()
                        .stroke(Color.green.opacity(0.9), lineWidth: 2)
                )
        }
    }
}
// MARK: - Warmup Game View
struct WarmupGameView: View {
    let currentQuestion: Int
    let warmupQuestions: [(prompt: String, answer: String, type: String)]
    @Binding var userAnswer: String
    @Binding var frogPosition: Int
    @Binding var showFeedback: Bool
    @Binding var isCorrect: Bool
    @Binding var warmupPoints: Int
    @Binding var frogIsJumping: Bool
    @Binding var frogRotation: Double
    let checkAnswer: () -> Void
    let performHop: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎮 Warm-Up: What Comes After?")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            // Pond Scene
            GeometryReader { geometry in
                ZStack {
                    // Pond background
                    PondBackground()
                    
                    // Lily pads - now with blank pads between questions
                    ForEach(0..<20, id: \.self) { index in
                        let xPosition = geometry.size.width * 0.05 + (geometry.size.width * 0.9 / 20) * CGFloat(index)
                        
                        VStack {
                            if index == 0 {
                                // Starting lily pad
                                LilyPadView(text: "Start", isCompleted: false, isBlank: true)
                            } else if index == 19 {
                                // Goal lily pad
                                VStack {
                                    Text("🏁")
                                        .font(.system(size: 30))
                                    Circle()
                                        .fill(Color.green.opacity(0.6))
                                        .frame(width: 70, height: 50)
                                        .overlay(
                                            Text("Goal")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        )
                                }
                            } else if index % 2 == 1 && index <= 17 {  // Only odd indices up to 17
                                // Question lily pads
                                let questionIndex = (index / 2)
                                if questionIndex < warmupQuestions.count {
                                    LilyPadView(
                                        text: warmupQuestions[questionIndex].prompt,
                                        isCompleted: questionIndex < currentQuestion,
                                        isBlank: false
                                    )
                                } else {
                                    // Extra blank pad if we run out of questions
                                    LilyPadView(text: "", isCompleted: false, isBlank: true)
                                }
                            } else {
                                // Blank lily pads (even positions)
                                LilyPadView(text: "", isCompleted: false, isBlank: true)
                            }
                        }
                        .position(x: xPosition, y: geometry.size.height * 0.6)
                    }
                    
                    // Frog Emoji
                    Text("🐸")
                        .font(.system(size: 50))
                        .rotationEffect(.degrees(frogRotation))
                        .position(
                            x: geometry.size.width * 0.05 + (geometry.size.width * 0.9 / 20) * CGFloat(frogPosition),
                            y: geometry.size.height * 0.35 - (frogIsJumping ? 40 : 0)
                        )
                        .animation(.spring(response: 0.6, dampingFraction: 0.6), value: frogPosition)
                        .animation(.easeInOut(duration: 0.3), value: frogIsJumping)
                }
            }
            .frame(height: 350)
            
            VStack(spacing: 20) {
                // Add a safety check here
                if currentQuestion < warmupQuestions.count {
                    Text("What comes after \(warmupQuestions[currentQuestion].prompt)?")
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        TextField("Your answer", text: $userAnswer)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 250)
                            .font(.title2)
                            .onSubmit {
                                checkAnswer()
                            }
                        
                        Button(action: checkAnswer) {
                            Text("Jump!")
                                .font(.title3)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    
                    // Feedback
                    if showFeedback {
                        Text(isCorrect ? "🎉 Correct! Great jump!" : "Not quite. Try again!")
                            .foregroundColor(isCorrect ? .green : .orange)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .animation(.easeIn, value: showFeedback)
                    }
                }
            }
            .padding()
        }
    }
}
// MARK: - Warmup Complete View
struct WarmupCompleteView: View {
    let points: Int
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🎉 Warm-Up Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your frog made it across the pond!")
                .font(.title2)
            
            FrogView(isJumping: false)
                .scaleEffect(2.0)
                .padding()
            
            Text("You earned \(points) points!")
                .font(.title2)
                .foregroundColor(.green)
                .fontWeight(.semibold)
            
            Button(action: onContinue) {  // Just call the passed-in function
                Text("Continue to Main Lesson")
                    .font(.title3)
                    .padding()
                    .frame(width: 350)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .padding(60)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .shadow(radius: 15)
        )
        .padding(50)
    }
}
