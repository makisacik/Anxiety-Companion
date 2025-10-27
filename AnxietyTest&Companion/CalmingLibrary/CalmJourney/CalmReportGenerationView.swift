//
//  CalmReportGenerationView.swift
//  AnxietyTest&Companion
//
//  Loading screen shown while generating the personalized Calm Journey report
//

import SwiftUI
struct CalmReportGenerationView: View {
    @State private var isLoading = true
    @State private var reportText: String? = nil
    @State private var error: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.purple, .blue], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                if let report = reportText {
                    CalmReportView(
                        report: report,
                        onClose: { dismiss() },
                        onShare: {}
                    )
                } else if let error = error {
                    VStack {
                        Text("Error: \(error)")
                        Button("Try Again") { generateReport() }
                    }
                } else {
                    VStack(spacing: 20) {
                        ProgressView("Generating your personalized report...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            }
            .onAppear { generateReport() }
            .navigationBarBackButtonHidden(true)
        }
    }

    @Environment(\.dismiss) private var dismiss

    private func generateReport() {
        // Simulated async GPT call
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            reportText = """
            ## Your Calm Journey Report
            You've made great progress...
            """
            isLoading = false
        }
    }
}
