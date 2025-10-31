//
//  CalmLevelDetailView.swift
//  AnxietyTest&Companion
//
//  Exercise list and sequential navigation for a specific Calm Journey level.
//

import SwiftUI

struct CalmLevelDetailView: View {
    let level: CalmLevel
    @Environment(\.dismiss) private var dismiss
    @State private var currentExerciseIndex = 0
    @State private var completedExercises: Set<Int> = []
    @State private var showCompletionMessage = false
    @State private var showExercise = false
    
    private var currentExercise: CalmExercise? {
        guard currentExerciseIndex < level.exercises.count else { return nil }
        return level.exercises[currentExerciseIndex]
    }
    
    private var isLastExercise: Bool {
        return currentExerciseIndex >= level.exercises.count - 1
    }
    
    private var allExercisesCompleted: Bool {
        return completedExercises.count == level.exercises.count
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground
                .ignoresSafeArea()
            
            if showExercise, let exercise = currentExercise {
                if exercise.type == .breathing {
                    CalmJourneyBreathingView(
                        exercise: exercise,
                        onComplete: {
                            handleExerciseCompletion(exercise)
                        }
                    )
                } else {
                    CalmExerciseView(
                        exercise: exercise,
                        onComplete: {
                            handleExerciseCompletion(exercise)
                        },
                        onNext: {
                            handleNextExercise()
                        }
                    )
                }
            } else if showCompletionMessage {
                completionView
            } else {
                exerciseListView
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadCompletedExercises()
        }
    }
    
    private var exerciseListView: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Button(action: {
                        HapticFeedback.light()
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.themeText)
                    }
                    
                    Spacer()
                    
                    Text(String.localizedStringWithFormat(String(localized: "journey_level"), level.id))
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                }
                
                Text(level.title)
                    .font(.system(.largeTitle, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.themeText)
                    .multilineTextAlignment(.center)
                
                Text(level.summary)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Progress indicator
            progressSection
            
            // Exercise list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(level.exercises.enumerated()), id: \.element.id) { index, exercise in
                        ExerciseRowView(
                            exercise: exercise,
                            index: index,
                            isCompleted: completedExercises.contains(exercise.id),
                            isCurrent: index == currentExerciseIndex,
                            onTap: {
                                startExercise(at: index)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Start/Continue button
            if !allExercisesCompleted {
                Button(action: {
                    startExercise(at: currentExerciseIndex)
                }) {
                    HStack {
                        Image(systemName: allExercisesCompleted ? "checkmark.circle.fill" : "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text(allExercisesCompleted ? String(localized: "level_detail_complete") : currentExerciseIndex == 0 ? String(localized: "level_detail_start") : String(localized: "level_detail_continue"))
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.themeText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.themeCard)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text(String(localized: "level_detail_progress"))
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.themeText)
                
                Spacer()
                
                Text(String.localizedStringWithFormat(String(localized: "session_step"), completedExercises.count, level.exercises.count))
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.7))
            }
            
            ProgressView(value: Double(completedExercises.count), total: Double(level.exercises.count))
                .progressViewStyle(LinearProgressViewStyle(tint: Color.themeText))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(.horizontal, 24)
    }
    
    private var completionView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Celebration
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.themeText)
                
                Text(String(localized: "level_detail_complete"))
                    .font(.system(.largeTitle, design: .serif))
                    .fontWeight(.bold)
                    .foregroundColor(.themeText)
                
                Text(String.localizedStringWithFormat(String(localized: "level_detail_completed_exercises"), level.title))
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Action buttons
            VStack(spacing: 16) {
                Button(action: {
                    HapticFeedback.success()
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text(String(localized: "completion_back_to_journey"))
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.themeText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.themeCard)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                
                Button(action: {
                    // Reset and restart level
                    currentExerciseIndex = 0
                    completedExercises.removeAll()
                    saveCompletedExercises()
                    showCompletionMessage = false
                    HapticFeedback.light()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .semibold))
                        Text(String(localized: "level_detail_repeat"))
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.themeText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.themeDivider, lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
    }
    
    private func startExercise(at index: Int) {
        currentExerciseIndex = index
        showExercise = true
        HapticFeedback.light()
    }
    
    private func handleExerciseCompletion(_ exercise: CalmExercise) {
        completedExercises.insert(exercise.id)
        saveCompletedExercises()
        HapticFeedback.success()
        
        if isLastExercise {
            showExercise = false
            showCompletionMessage = true
        } else {
            handleNextExercise()
        }
    }
    
    private func handleNextExercise() {
        if isLastExercise {
            showExercise = false
            showCompletionMessage = true
        } else {
            currentExerciseIndex += 1
            // Stay in exercise view for next exercise
        }
    }
    
    private func loadCompletedExercises() {
        let key = "completedExercises_Level\(level.id)"
        if let data = UserDefaults.standard.data(forKey: key),
           let exercises = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            completedExercises = exercises
        }
    }
    
    private func saveCompletedExercises() {
        let key = "completedExercises_Level\(level.id)"
        if let data = try? JSONEncoder().encode(completedExercises) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

struct ExerciseRowView: View {
    let exercise: CalmExercise
    let index: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Exercise number/status
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.themeText : (isCurrent ? Color.themeText.opacity(0.3) : Color.themeDivider.opacity(0.5)))
                        .frame(width: 40, height: 40)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(.body, weight: .semibold))
                            .foregroundColor(.themeBackground)
                    } else {
                        Text("\(index + 1)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(isCurrent ? .themeText : .themeText.opacity(0.6))
                    }
                }
                
                // Exercise info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: exercise.icon)
                            .font(.system(.caption, weight: .medium))
                            .foregroundColor(.themeText.opacity(0.7))
                        
                        Text(exercise.title)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(isCompleted ? .themeText : (isCurrent ? .themeText : .themeText.opacity(0.7)))
                        
                        Spacer()
                        
                        if isCurrent && !isCompleted {
                            Image(systemName: "play.circle.fill")
                                .font(.system(.title3))
                                .foregroundColor(.themeText)
                        }
                    }
                    
                    Text(exercise.displayType)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.6))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.themeCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCurrent ? Color.themeText.opacity(0.3) : Color.themeDivider.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    CalmLevelDetailView(level: CalmJourneyDataStore.shared.levels[0])
}
