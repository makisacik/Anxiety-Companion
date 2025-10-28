//
//  PaywallView.swift
//  AnxietyTest&Companion
//
//  Redesigned paywall UI (design-only, no StoreKit yet)
//  to match the provided mock, using the app theme.
//

import SwiftUI

struct PaywallView: View {
    enum PlanOption: String, CaseIterable { case yearly, weeklyTrial }

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanOption = .weeklyTrial

    // Note: This view is design-only. Button actions are placeholders.
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.themeBackground
                .ignoresSafeArea()

            // Close button
            Button(action: { HapticFeedback.light(); dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.themeText.opacity(0.7))
                    .padding(12)
            }
            .padding(.trailing, 8)
            .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Top illustration
                    Image("paywall image")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .padding(.top, 20)

                    // Title
                    VStack(spacing: 8) {
                        Text("Unlimited Access")
                            .font(.system(.largeTitle, design: .serif))
                            .fontWeight(.bold)
                            .foregroundColor(.themeText)
                        
                        // Benefits list (app content)
                        VStack(alignment: .leading, spacing: 14) {
                            benefitRow(icon: "wind", text: "Guided breathing and relaxation")
                            benefitRow(icon: "pencil.line", text: "Daily reflections and mood tracking")
                            benefitRow(icon: "location", text: "Personalized insights and reminders")
                            benefitRow(icon: "fork.knife", text: "Tips for calm habits and routines")
                        }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal, 24)

                    // Plans section
                    VStack(spacing: 12) {
                        planRow(
                            title: "Yearly Plan",
                            subtitle: "$39.99 per year",
                            leadingStrikethrough: "$415.48",
                            badge: "SAVE 90%",
                            isSelected: selectedPlan == .yearly,
                            trailing: nil
                        ) { selectedPlan = .yearly }

                        planRow(
                            title: "3-Day Trial",
                            subtitle: "then $7.99 per week",
                            leadingStrikethrough: nil,
                            badge: nil,
                            isSelected: selectedPlan == .weeklyTrial,
                            trailing: Text("FREE")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.themeText)
                        ) { selectedPlan = .weeklyTrial }
                    }
                    .padding(.horizontal, 20)

                    // Toggle
                    HStack {
                        Text("Free Trial Enabled")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.themeText)
                        Spacer()
                        Toggle("", isOn: .constant(selectedPlan == .weeklyTrial))
                            .labelsHidden()
                            .allowsHitTesting(false) // display-only
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.themeCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.themeDivider, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)

                    // CTA
                    Button(action: { HapticFeedback.soft() /* no StoreKit yet */ }) {
                        HStack(spacing: 8) {
                            Text("Try for Free")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.themeBackgroundPure)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.themeBackgroundPure)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            // Shiny gradient button
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.themeText, Color.themeCompanionDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            // Glossy top highlight
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.themeBackgroundPure.opacity(0.35), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .allowsHitTesting(false)
                        )
                        .overlay(
                            // Subtle border
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.themeBackgroundPure.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: Color.themeText.opacity(0.25), radius: 8, x: 0, y: 6)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 20)

                    // Footer
                    HStack(spacing: 20) {
                        Button("Restore") { HapticFeedback.light() }
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.7))
                    }
                    .padding(.bottom, 28)
                }
            }
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.themeText)
                .frame(width: 26)
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.themeText)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func planRow(
        title: String,
        subtitle: String,
        leadingStrikethrough: String?,
        badge: String?,
        isSelected: Bool,
        trailing: Text?,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: { HapticFeedback.light(); onTap() }) {
            HStack(alignment: .center, spacing: 14) {
                // Radio
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isSelected ? .themeText : .themeText.opacity(0.5))
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.themeText)

                        if let badge = badge {
                            Text(badge)
                                .font(.system(.caption2, design: .rounded))
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule().fill(Color.themeText.opacity(0.12))
                                )
                                .foregroundColor(.themeText)
                        }
                    }

                    HStack(spacing: 6) {
                        if let strike = leadingStrikethrough {
                            Text(strike)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.6))
                                .strikethrough(true, color: Color.themeText.opacity(0.6))
                        }
                        Text(subtitle)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.themeText.opacity(0.9))
                    }
                }

                Spacer()

                if let trailing = trailing {
                    trailing
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.themeCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.themeDivider, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview { PaywallView() }
