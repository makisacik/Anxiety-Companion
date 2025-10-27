//
//  CalmReportGenerationView.swift
//  AnxietyTest&Companion
//
//  Loading screen shown while generating the personalized Calm Journey report
//

import SwiftUI

struct CalmReportGenerationView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isLoading = true
    @State private var reportText: String?
    @State private var errorMessage: String?
    @State private var reportSections: [ReportSection] = []
    @State private var highlights: [ReportHighlight] = []
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            themeBackground
            content
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    HapticFeedback.light()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
            }

            ToolbarItem(placement: .principal) {
                Text("Calm Report")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white)
            }

            ToolbarItem(placement: .topBarTrailing) {
                if reportText != nil {
                    Button {
                        HapticFeedback.light()
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [reportText ?? ""])
        }
        .onAppear {
            guard reportText == nil, errorMessage == nil else { return }
            generateReport()
        }
    }

    private var themeBackground: some View {
        LinearGradient(
            colors: [Color(hex: "#6E63A4"), Color(hex: "#B5A7E0")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            loadingView
        } else if let errorMessage {
            errorView(message: errorMessage)
        } else if reportText != nil {
            loadedView
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            Text("Gathering your notes...")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Text("Something went wrong")
                .font(.system(.title3, design: .rounded).bold())
                .foregroundColor(.white)
            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
            Button {
                HapticFeedback.light()
                generateReport()
            } label: {
                Text("Try Again")
                    .font(.system(.body, design: .rounded).bold())
                    .foregroundColor(Color(hex: "#6E63A4"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 60)
        }
        .padding()
    }

    private var loadedView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                heroSection

                if !highlights.isEmpty {
                    highlightSection
                }

                ForEach(reportSections) { section in
                    ReportSectionView(section: section)
                }

                encouragementFooter
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .padding(.top, 12)
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("You're building a calmer rhythm")
                .font(.system(.title2, design: .rounded).bold())
                .foregroundColor(.white)

            Text("A quick reflection on how you're supporting your nervous system.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.9))

            Divider()
                .background(Color.white.opacity(0.2))

            HStack(spacing: 16) {
                InsightChip(icon: "heart.fill", text: "Ground faster")
                InsightChip(icon: "sparkles", text: "Spot strengths")
                InsightChip(icon: "leaf.fill", text: "Breathe with purpose")
            }
            .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
        )
    }

    private var highlightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Moments to celebrate")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white.opacity(0.9))

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(highlights) { highlight in
                    VStack(alignment: .leading, spacing: 12) {
                        Image(systemName: highlight.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(hex: "#6E63A4"))
                            .padding(10)
                            .background(Circle().fill(Color.white.opacity(0.85)))

                        Text(highlight.title)
                            .font(.system(.subheadline, design: .rounded).bold())
                            .foregroundColor(.white)

                        Text(highlight.detail)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(3)
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }

    private var encouragementFooter: some View {
        VStack(spacing: 12) {
            Text("Keep listening to your calm moments")
                .font(.system(.headline, design: .rounded).bold())
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Small practices add up. Each return builds more trust in your calm.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private func generateReport() {
        isLoading = true
        errorMessage = nil

        // Simulated async GPT call
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let generatedReport = """
            ## Emotional Notes
            You name feelings sooner and speak to yourself with more care.

            ## Wins Worth Noticing
            You pause before anxious spirals, use your breathing tool, and credit the effort it takes.

            ## Supportive Reminders
            Celebrate small shifts, lean on grounding prompts, and jot down the moments that feel steady.
            """

            reportText = generatedReport
            reportSections = parseReportSections(from: generatedReport)
            highlights = deriveHighlights(from: reportSections)
            isLoading = false
        }
    }

    private func parseReportSections(from report: String) -> [ReportSection] {
        let rawSections = report.components(separatedBy: "## ")
        var parsed: [ReportSection] = []

        for raw in rawSections {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let lines = trimmed.components(separatedBy: "\n")
            guard let firstLine = lines.first else { continue }

            let title = firstLine.trimmingCharacters(in: .whitespacesAndNewlines)
            let content = lines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

            guard !title.isEmpty else { continue }
            parsed.append(
                ReportSection(
                    title: title,
                    content: content.isEmpty ? "Keep following the practices that feel supportive." : content,
                    icon: icon(for: title)
                )
            )
        }

        if parsed.isEmpty {
            parsed.append(
                ReportSection(
                    title: "Your Calm Journey",
                    content: "Your reflections highlight growing awareness, kinder self-talk, and practical tools that now feel familiar.",
                    icon: "sparkles"
                )
            )
        }

        return parsed
    }

    private func deriveHighlights(from sections: [ReportSection]) -> [ReportHighlight] {
        var result: [ReportHighlight] = []
        let icons = ["heart.circle.fill", "sparkle.magnifyingglass", "leaf.fill", "sun.max.fill"]

        for (index, section) in sections.enumerated() {
            guard result.count < 4 else { break }
            let detail = firstSentence(from: section.content)
            guard !detail.isEmpty else { continue }

            let title: String
            if index == 0 {
                title = "Emotional Growth"
            } else if index == 1 {
                title = "What You Did Well"
            } else {
                title = section.title
            }

            result.append(
                ReportHighlight(
                    title: title,
                    detail: detail,
                    icon: icons[index % icons.count]
                )
            )
        }

        if result.isEmpty {
            result.append(
                ReportHighlight(
                    title: "Showing Up",
                    detail: "Even noticing how you feel is a powerful practice—keep honoring that awareness.",
                    icon: "sparkles"
                )
            )
        }

        return result
    }

    private func firstSentence(from text: String) -> String {
        let delimiters: CharacterSet = [".", "!", "?"]
        let components = text.components(separatedBy: delimiters)
        guard let first = components.first?.trimmingCharacters(in: .whitespacesAndNewlines), !first.isEmpty else {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return first
    }

    private func icon(for title: String) -> String {
        let lower = title.lowercased()
        if lower.contains("emotional") { return "heart.circle.fill" }
        if lower.contains("win") { return "sparkles" }
        if lower.contains("reminder") { return "leaf.fill" }
        if lower.contains("progress") { return "chart.bar.fill" }
        if lower.contains("journey") { return "compass.fill" }
        return "sparkles"
    }
}

private struct ReportSection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let icon: String
}

private struct ReportHighlight: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let icon: String
}

private struct InsightChip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
            Text(text)
                .font(.system(.caption, design: .rounded).bold())
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.12))
        )
    }
}

private struct ReportSectionView: View {
    let section: ReportSection

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color(hex: "#6E63A4"))
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.85)))

                Text(section.title)
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundColor(.white)
            }

            Text(section.content)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                )
        )
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CalmReportGenerationView()
}
