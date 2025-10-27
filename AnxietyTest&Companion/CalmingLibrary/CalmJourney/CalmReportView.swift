//
//  CalmReportView.swift
//  AnxietyTest&Companion
//
//  Displays the personalized Calm Journey report with warm, readable typography
//

import SwiftUI

struct CalmReportView: View {
    let report: String
    let onClose: () -> Void
    let onShare: () -> Void
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showShareSheet = false
    
    init(report: String, onClose: @escaping () -> Void, onShare: @escaping () -> Void) {
        self.report = report
        self.onClose = onClose
        self.onShare = onShare
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Report content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(parseReportSections(), id: \.title) { section in
                            ReportSectionView(section: section)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100) // Space for bottom buttons
                }
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    }
                )
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
            }
            
            // Bottom action buttons
            VStack {
                Spacer()
                bottomActionButtons
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [report])
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    HapticFeedback.light()
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.2))
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                
                Spacer()
                
                Button(action: {
                    HapticFeedback.light()
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.2))
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text("Your Calm Journey Report 🌿")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("A personalized reflection on your growth")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(
            // Blur effect that changes with scroll
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(max(0, min(1, scrollOffset / 100)))
        )
    }
    
    private var bottomActionButtons: some View {
        VStack(spacing: 16) {
            // Share button
            Button(action: {
                HapticFeedback.light()
                showShareSheet = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Share Report")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }
                .foregroundColor(Color(hex: "#6E63A4"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(radius: 3)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            
            // Close button
            Button(action: {
                HapticFeedback.light()
                onClose()
            }) {
                Text("Close")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 34)
        .background(
            // Gradient overlay for better text readability
            LinearGradient(
                colors: [
                    Color.clear,
                    Color(hex: "#6E63A4").opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .allowsHitTesting(false)
        )
    }
    
    private func parseReportSections() -> [ReportSection] {
        // Split by ## headers (markdown format)
        let sections = report.components(separatedBy: "## ")
        var parsedSections: [ReportSection] = []
        
        for (index, section) in sections.enumerated() {
            let lines = section.components(separatedBy: "\n")
            guard !lines.isEmpty else { continue }
            
            let firstLine = lines[0].trimmingCharacters(in: .whitespaces)
            let content = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespaces)
            
            // Skip empty sections
            if firstLine.isEmpty && content.isEmpty { continue }
            
            // For the first section (before any ##), treat as introduction
            if index == 0 {
                if !content.isEmpty {
                    parsedSections.append(ReportSection(title: "Introduction", content: content))
                }
            } else {
                // This is a ## header section
                let title = firstLine.replacingOccurrences(of: "^#+\\s*", with: "", options: .regularExpression)
                parsedSections.append(ReportSection(title: title, content: content))
            }
        }
        
        return parsedSections
    }
}

struct ReportSection {
    let title: String
    var content: String
}

struct ReportSectionView: View {
    let section: ReportSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.title2.bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Text(section.content)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CalmReportView(
        report: """
        1. Introduction
        
        You've shown remarkable courage in taking this journey toward greater calm and self-understanding. Your commitment to exploring your inner world and building new habits speaks to a deep desire for growth and peace.
        
        2. Emotional Themes
        
        Throughout your reflections, I notice a growing awareness of your emotional patterns. You've started to recognize when anxiety appears and have developed more compassionate ways of responding to difficult feelings.
        
        3. Strengths You've Shown
        
        Your willingness to be honest about your struggles while also celebrating small victories shows incredible emotional maturity. You've demonstrated resilience in trying new coping strategies even when they felt uncomfortable.
        """,
        onClose: {},
        onShare: {}
    )
}
