//
//  CompanionFaceView.swift
//
//
//  Created by Mehmet Ali Kısacık on 25.10.2025.
//

import SwiftUI

struct CompanionFaceView: View {
    enum Expression {
        case neutral, happy, mouthLeft, mouthRight, calm, smile
    }

    var expression: Expression = .neutral
    var showGlow: Bool = false
    var animateBreathing: Bool = true
    var size: CGFloat = 120

    @State private var blink = false
    @State private var breathing = false
    @State private var glowPulse = false
    @State private var blinkTimer: Timer?

    var body: some View {
        GeometryReader { geometry in
            let actualSize = min(geometry.size.width, geometry.size.height)
            let scaleFactor = actualSize / 120.0 // Base size reference
            
            ZStack {
                // Body (orb)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.themeCompanionLight, // soft light gray
                                Color.themeCompanionMid,   // main gray tone
                                Color.themeCompanionDark   // deeper gray
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: actualSize, height: actualSize)
                .scaleEffect(animateBreathing ? (breathing ? 1.05 : 0.95) : 1.0)
                .animation(
                    animateBreathing
                    ? .easeInOut(duration: 3).repeatForever(autoreverses: true)
                    : .default,
                    value: breathing
                )
                .overlay(faceLayer(scaleFactor: scaleFactor))
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
                                endRadius: actualSize * 0.67
                            )
                        )
                        .scaleEffect(glowPulse ? 1.2 : 0.8)
                        .opacity(showGlow ? 1 : 0)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: glowPulse)
                )
            }
            .frame(width: actualSize, height: actualSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .frame(width: 120, height: 120)
        .onAppear {
            if animateBreathing {
                breathing.toggle()
            }
            startBlinking()
            if showGlow {
                startGlowPulse()
            }
        }
        .onDisappear {
            stopBlinking()
        }
        .onChange(of: showGlow) { newValue in
            if newValue {
                startGlowPulse()
            } else {
                glowPulse = false
            }
        }
    }

    // MARK: - Face Layout
    private func faceLayer(scaleFactor: CGFloat) -> some View {
        VStack(spacing: 10 * scaleFactor) {
            // Eyes
            HStack(spacing: 30 * scaleFactor) {
                eye(scaleFactor: scaleFactor)
                eye(scaleFactor: scaleFactor)
            }
            // Mouth
            mouth(scaleFactor: scaleFactor)
        }
    }

    private func eye(scaleFactor: CGFloat) -> some View {
        let baseWidth = expression == .calm ? 6.0 : 8.0
        let blinkWidth = 2.0
        
        return Capsule()
            .fill(Color.themeCompanionOutline)
            .frame(
                width: (blink ? blinkWidth : baseWidth) * scaleFactor,
                height: 8 * scaleFactor
            )
            .animation(.easeInOut(duration: 0.2), value: blink)
    }

    // MARK: - Mouth
    @ViewBuilder
    private func mouth(scaleFactor: CGFloat) -> some View {
        switch expression {
        case .happy, .smile:
            // gentle smile curve (visible but subtle)
            HappyMouthShape()
                .stroke(Color.themeCompanionOutline, lineWidth: 3 * scaleFactor)
                .frame(width: 36 * scaleFactor, height: 10 * scaleFactor)
                .offset(y: 5 * scaleFactor)
                .transition(.opacity)
        default:
            // straight or tilted line for other moods
            RoundedRectangle(cornerRadius: 3 * scaleFactor)
                .fill(Color.themeCompanionOutline)
                .frame(width: 30 * scaleFactor, height: 3 * scaleFactor)
                .rotationEffect(mouthRotation)
                .offset(x: mouthOffsetX * scaleFactor, y: mouthOffsetY * scaleFactor)
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
        // Invalidate any existing timer first
        blinkTimer?.invalidate()
        
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
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
    
    private func stopBlinking() {
        blinkTimer?.invalidate()
        blinkTimer = nil
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

#Preview {
    VStack(spacing: 20) {
        CompanionFaceView(expression: .neutral)
        CompanionFaceView(expression: .happy)
        CompanionFaceView(expression: .mouthLeft)
        CompanionFaceView(expression: .mouthRight)
        CompanionFaceView(expression: .calm)
        CompanionFaceView(expression: .smile)
        CompanionFaceView(expression: .happy, showGlow: true)
    }
    .padding()
    .background(Color.black)
}
