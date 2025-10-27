//
//  CalmReportView.swift
//  AnxietyTest&Companion
//
//  Displays the personalized Calm Journey report with warm, readable typography
//

import SwiftUI

/// Legacy wrapper maintained for compatibility. Prefer using `CalmReportGenerationView` directly.
@available(*, deprecated, message: "Use CalmReportGenerationView instead.")
struct CalmReportView: View {
    let report: String

    var body: some View {
        CalmReportGenerationView()
    }
}

#Preview {
    CalmReportGenerationView()
}
