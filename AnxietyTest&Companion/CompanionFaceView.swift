//
//  CompanionFaceView.swift
//
//
//  Created by Mehmet Ali Kısacık on 25.10.2025.
//

import SwiftUI

struct CompanionFaceView: View {
    enum Expression {
        case neutral, happy, mouthLeft, mouthRight
    }

    var expression: Expression = .neutral
    var showGlow: Bool = false

    @State private var blink = false
    @State private var breathing = false
    @State private var glowPulse = false

    var body: some View {
        ZStack {
            // Body (orb)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#E2D9F7"), // soft light lavender
                            Color(hex: "#B5A7E0"), // main lavender tone
                            Color(hex: "#A493D6")  // deeper lavender
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(breathing ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: breathing)
                .overlay(faceLayer)
                .overlay(
                    // Glow effect for final screen
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(showGlow ? 0.3 : 0),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .scaleEffect(glowPulse ? 1.2 : 0.8)
                        .opacity(showGlow ? 1 : 0)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: glowPulse)
                )
        }
        .onAppear {
            breathing.toggle()
            startBlinking()
            if showGlow {
                startGlowPulse()
            }
        }
        .onChange(of: showGlow) { _, newValue in
            if newValue {
                startGlowPulse()
            } else {
                glowPulse = false
            }
        }
    }

    // MARK: - Face Layout
    private var faceLayer: some View {
        VStack(spacing: 10) {
            // Eyes
            HStack(spacing: 30) {
                eye
                eye
            }
            // Mouth
            mouth
        }
    }

    private var eye: some View {
        Capsule()
            .fill(Color.black.opacity(0.6))
            .frame(width: blink ? 2 : 8, height: 8)
            .animation(.easeInOut(duration: 0.2), value: blink)
    }

    // MARK: - Mouth
    @ViewBuilder
    private var mouth: some View {
        switch expression {
        case .happy:
            // gentle smile curve (visible but subtle)
            HappyMouthShape()
                .stroke(Color.black.opacity(0.6), lineWidth: 3)
                .frame(width: 36, height: 10)
                .offset(y: 5)
                .transition(.opacity)
        default:
            // straight or tilted line for other moods
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.black.opacity(0.5))
                .frame(width: 30, height: 3)
                .rotationEffect(mouthRotation)
                .offset(x: mouthOffsetX, y: mouthOffsetY)
                .transition(.opacity)
        }
    }

    private var mouthRotation: Angle {
        switch expression {
        case .mouthLeft:
            return .degrees(8)
        case .mouthRight:
            return .degrees(-8)
        default:
            return .degrees(0)
        }
    }

    private var mouthOffsetX: CGFloat {
        switch expression {
        case .mouthLeft:
            return -8
        case .mouthRight:
            return 8
        default:
            return 0
        }
    }

    private var mouthOffsetY: CGFloat {
        expression == .happy ? 6 : 4
    }

    // MARK: - Blink
    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                blink = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    blink = false
                }
            }
        }
    }

    // MARK: - Glow Pulse
    private func startGlowPulse() {
        glowPulse = true
    }
}

// MARK: - Smile Shape
struct HappyMouthShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let smileDepth: CGFloat = 4
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control: CGPoint(x: rect.midX, y: rect.midY + smileDepth)
        )
        return path
    }
}

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

#Preview {
    VStack(spacing: 20) {
        CompanionFaceView(expression: .neutral)
        CompanionFaceView(expression: .happy)
        CompanionFaceView(expression: .mouthLeft)
        CompanionFaceView(expression: .mouthRight)
        CompanionFaceView(expression: .happy, showGlow: true)
    }
    .padding()
    .background(Color.black)
}
