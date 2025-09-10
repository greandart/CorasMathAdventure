import SwiftUI

// MARK: - Data Models
struct Lesson: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let icon: String
    let description: String
    var isUnlocked: Bool
    var isCompleted: Bool
    let maxPoints: Int
    var earnedPoints: Int
}

// MARK: - Main Content View
struct ContentView: View {
    func updateProgress(lessonNumber: Int, pointsEarned: Int) {
        playerProgress.totalPoints += pointsEarned
        playerProgress.currentLevel = (playerProgress.totalPoints / 100) + 1
        playerProgress.unicornProgress = Double(playerProgress.totalPoints % 100) / 100.0
        
        if !playerProgress.completedLessons.contains(lessonNumber) {
            playerProgress.completedLessons.append(lessonNumber)
        }
        playerProgress.lessonScores[lessonNumber] = pointsEarned
        playerProgress.save()
        
        // Update the lesson as completed
        if let index = lessons.firstIndex(where: { $0.number == lessonNumber }) {
            lessons[index].isCompleted = true
            lessons[index].earnedPoints = pointsEarned
        }
    }
    @State private var showingLesson29 = false
    @State private var playerProgress = PlayerProgress.load()
    
    // Starting with just Lesson 29 and one locked lesson
    @State private var lessons = [
        Lesson(number: 29, title: "Tens and Ones", icon: "🧮", description: "Place value & triangles", isUnlocked: true, isCompleted: false, maxPoints: 100, earnedPoints: 0),
        Lesson(number: 30, title: "Coming Soon", icon: "❓", description: "Complete Lesson 29 to unlock", isUnlocked: false, isCompleted: false, maxPoints: 100, earnedPoints: 0),
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Panel - Progress & Unicorn
            VStack(spacing: 20) {
                // Score Display
                VStack(spacing: 15) {
                    Text("🏆 Total Score")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("\(playerProgress.totalPoints)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.purple)
                    
                    // Level Progress
                    VStack(spacing: 8) {
                        Text("Level \(playerProgress.currentLevel)")
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        ProgressView(value: Double(playerProgress.totalPoints % 100), total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                            .padding(.horizontal)
                        
                        Text("\(100 - (playerProgress.totalPoints % 100)) points to Level \(playerProgress.currentLevel + 1)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Reset Button
                    Button(action: {
                        playerProgress = PlayerProgress(
                            totalPoints: 0,
                            currentLevel: 1,
                            completedLessons: [],
                            lessonScores: [:],
                            unicornProgress: 0,
                            lastPlayed: Date()
                        )
                        playerProgress.save()
                        
                        // Reset lessons
                        lessons[0].isCompleted = false
                        lessons[0].earnedPoints = 0
                        if lessons.count > 1 {
                            lessons[1].isUnlocked = false
                        }
                    }) {
                        Text("Reset Progress")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.top, 10)
                    }
                }  // This closes the Score Display VStack
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // Mountain Climbing Unicorn continues here...
                MountainClimbView(progress: playerProgress.unicornProgress, level: playerProgress.currentLevel)
                    .frame(height: 400)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                
                Spacer()
            }  // This closes the left panel VStack
            .frame(width: 350)
            .padding()
            .background(Color.gray.opacity(0.05))
            // Right Panel - Lessons Grid
            VStack(alignment: .leading, spacing: 20) {
                Text("Cora's Math Journey")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)
                
                Text("Complete lessons to earn points and help the unicorn climb the mountain!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(lessons) { lesson in
                            LessonCard(lesson: lesson, showingLesson29: $showingLesson29)
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minWidth: 1200, minHeight: 800)
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)]),
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing))
        .sheet(isPresented: $showingLesson29) {
            Lesson29View(
                totalPoints: Binding(
                    get: { playerProgress.totalPoints },
                    set: { newValue in
                        playerProgress.totalPoints = newValue
                        playerProgress.currentLevel = (newValue / 100) + 1
                        playerProgress.unicornProgress = Double(newValue % 100) / 100.0
                        playerProgress.save()
                    }
                ),
                lessonCompleted: .constant(false)
            )
        }
        .onAppear {
            loadProgress()
        }
    }
    
    func loadProgress() {
        // Update lesson states based on saved data
        for i in 0..<lessons.count {
            if playerProgress.completedLessons.contains(lessons[i].number) {
                lessons[i].isCompleted = true
                lessons[i].earnedPoints = playerProgress.lessonScores[lessons[i].number] ?? 0
            }
            // Unlock next lesson if previous is completed
            if i > 0 && lessons[i-1].isCompleted {
                lessons[i].isUnlocked = true
            }
        }
    }
}

// MARK: - Mountain Climb View
struct MountainClimbView: View {
    let progress: CGFloat
    let level: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky background
                LinearGradient(gradient: Gradient(colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)]),
                              startPoint: .top,
                              endPoint: .bottom)
                
                // Clouds
                CloudShape()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: geometry.size.width * 0.25, height: geometry.size.height * 0.1)
                    .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.2)

                CloudShape()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.12)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.3)
                
                // Background hills
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.6))
                    path.addQuadCurve(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.7),
                                      control: CGPoint(x: geometry.size.width * 0.25, y: geometry.size.height * 0.5))
                    path.addQuadCurve(to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.65),
                                      control: CGPoint(x: geometry.size.width * 0.75, y: geometry.size.height * 0.55))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(Color.green.opacity(0.4))
                
                // Main Mountain
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.15))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.85, y: geometry.size.height * 0.9))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.15, y: geometry.size.height * 0.9))
                    path.closeSubpath()
                }
                .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.94), Color.gray.opacity(0.7)]),
                                    startPoint: .top,
                                    endPoint: .bottom))
                
                // Mountain details - ridges
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.15))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.5))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.45, y: geometry.size.height * 0.9))
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.15))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.45))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.55, y: geometry.size.height * 0.9))
                }
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                
                // Snow cap
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.15))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.65, y: geometry.size.height * 0.35))
                    path.addCurve(to: CGPoint(x: geometry.size.width * 0.35, y: geometry.size.height * 0.35),
                                 control1: CGPoint(x: geometry.size.width * 0.55, y: geometry.size.height * 0.32),
                                 control2: CGPoint(x: geometry.size.width * 0.45, y: geometry.size.height * 0.32))
                    path.closeSubpath()
                }
                .fill(Color.white)
                
                // Snow highlights
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.52, y: geometry.size.height * 0.2))
                    path.addCurve(to: CGPoint(x: geometry.size.width * 0.58, y: geometry.size.height * 0.28),
                                 control1: CGPoint(x: geometry.size.width * 0.55, y: geometry.size.height * 0.22),
                                 control2: CGPoint(x: geometry.size.width * 0.57, y: geometry.size.height * 0.25))
                }
                .stroke(Color.blue.opacity(0.2), lineWidth: 3)
                
                // Path up the mountain (zigzag trail)
                Path { path in
                    path.move(to: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.9))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.75))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.6))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.55, y: geometry.size.height * 0.45))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.45, y: geometry.size.height * 0.3))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.15))
                }
                .stroke(Color.brown.opacity(0.6), style: StrokeStyle(lineWidth: 4, dash: [8, 4]))
                
                // Trees at the base
                ForEach(0..<5) { i in
                    let xPos = geometry.size.width * (0.1 + Double(i) * 0.2)
                    let yPos = geometry.size.height * 0.85
                    
                    TreeShape()
                        .fill(Color.green.opacity(0.8))
                        .frame(width: 30, height: 40)
                        .position(x: xPos, y: yPos)
                }
                
                // Unicorn position calculation
                let positions: [CGPoint] = [
                    CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.9),
                    CGPoint(x: geometry.size.width * 0.6, y: geometry.size.height * 0.75),
                    CGPoint(x: geometry.size.width * 0.4, y: geometry.size.height * 0.6),
                    CGPoint(x: geometry.size.width * 0.55, y: geometry.size.height * 0.45),
                    CGPoint(x: geometry.size.width * 0.45, y: geometry.size.height * 0.3),
                    CGPoint(x: geometry.size.width * 0.5, y: geometry.size.height * 0.15)
                ]
                
                let positionIndex = Int(progress * 5)
                let unicornPosition = positions[min(positionIndex, positions.count - 1)]
                
                // Unicorn
                Text("🦄")
                    .font(.system(size: 45))
                    .position(unicornPosition)
                    .shadow(radius: 3)
                
                // Level checkpoints
                ForEach(1...5, id: \.self) { checkpointLevel in
                    let checkpoint = positions[checkpointLevel]
                    
                    VStack(spacing: 2) {
                        Image(systemName: checkpointLevel == 1 ? "star.fill" : "flag.fill")
                            .foregroundColor(checkpointLevel <= level ? .yellow : .gray)
                            .font(.system(size: 18))
                        Text("Lv \(checkpointLevel)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(checkpointLevel <= level ? .primary : .secondary)
                    }
                    .position(x: checkpoint.x + 35, y: checkpoint.y - 10)
                }
                
                // Summit crown
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 30))
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.08)
                    .opacity(level >= 5 ? 1.0 : 0.3)
                    .rotationEffect(.degrees(level >= 5 ? 360 : 0))
                    .animation(.easeInOut(duration: 1), value: level)
                
                // Sun
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 50, height: 50)
                    .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
                    .overlay(
                        Circle()
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 10)
                            .frame(width: 60, height: 60)
                            .position(x: geometry.size.width * 0.85, y: geometry.size.height * 0.15)
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

// MARK: - Lesson Card
struct LessonCard: View {
    let lesson: Lesson
    @Binding var showingLesson29: Bool
    @State private var isHovering = false
    
    var body: some View {
        Button(action: {
            if lesson.number == 29 && lesson.isUnlocked {
                showingLesson29 = true
            }
        }) {
            VStack(spacing: 12) {
                // Icon with completion status
                ZStack {
                    Circle()
                        .fill(lesson.isCompleted ? Color.green.opacity(0.2) :
                              lesson.isUnlocked ? Color.blue.opacity(0.2) :
                              Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Text(lesson.icon)
                        .font(.system(size: 40))
                        .opacity(lesson.isUnlocked ? 1 : 0.5)
                    
                    if lesson.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                            .offset(x: 30, y: -30)
                    }
                    
                    if !lesson.isUnlocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                            .offset(x: 30, y: -30)
                    }
                }
                
                // Lesson info
                VStack(spacing: 4) {
                    Text("Lesson \(lesson.number)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(lesson.title)
                        .font(.headline)
                        .foregroundColor(lesson.isUnlocked ? .primary : .secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(lesson.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                // Points earned
                if lesson.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("\(lesson.earnedPoints)/\(lesson.maxPoints)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .frame(width: 200, height: 200)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: isHovering ? 8 : 3)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lesson.isCompleted ? Color.green :
                           lesson.isUnlocked ? Color.blue :
                           Color.gray, lineWidth: 2)
            )
            .scaleEffect(isHovering && lesson.isUnlocked ? 1.05 : 1)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!lesson.isUnlocked)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
// MARK: - Cloud Shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Left bubble
        path.addEllipse(in: CGRect(x: rect.width * 0.1,
                                   y: rect.height * 0.4,
                                   width: rect.width * 0.35,
                                   height: rect.height * 0.5))
        
        // Center bubble
        path.addEllipse(in: CGRect(x: rect.width * 0.25,
                                   y: rect.height * 0.25,
                                   width: rect.width * 0.5,
                                   height: rect.height * 0.6))
        
        // Right bubble
        path.addEllipse(in: CGRect(x: rect.width * 0.5,
                                   y: rect.height * 0.35,
                                   width: rect.width * 0.4,
                                   height: rect.height * 0.5))
        
        return path
    }
}

// MARK: - Tree Shape
struct TreeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Tree trunk
        path.addRect(CGRect(x: rect.midX - rect.width * 0.1,
                           y: rect.height * 0.7,
                           width: rect.width * 0.2,
                           height: rect.height * 0.3))
        // Tree top (triangle)
        path.move(to: CGPoint(x: rect.midX, y: rect.height * 0.2))
        path.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.75))
        path.addLine(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.75))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
#Preview {
    ContentView()
    
}
