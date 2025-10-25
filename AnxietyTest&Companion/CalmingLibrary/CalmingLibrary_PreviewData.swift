//
//  CalmingLibrary_PreviewData.swift
//  AnxietyTest&Companion
//
//  Preview helper for SwiftUI canvas.
//

import SwiftUI

#Preview("Calming Library") {
    NavigationStack {
        CalmingLibraryView()
    }
}

#Preview("Calming Card") {
    NavigationStack {
        CalmingCardView(activity: CalmingActivityStore.shared.activities[1])
    }
}

#Preview("Guided Breathing") {
    NavigationStack {
        GuidedBreathingView()
    }
}
