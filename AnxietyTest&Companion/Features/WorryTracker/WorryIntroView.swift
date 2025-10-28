import SwiftUI

struct WorryIntroView: View {
    @AppStorage("hasSeenWorryIntro") private var hasSeenWorryIntro = false
    @Binding var isPresented: Bool
    
    @State private var step = 0
    @State private var breathing = false
    @State private var progress: CGFloat = 0.0
    @State private var fadeOut = false
    
    let scenes: [(emoji: String, text: String)] = [
        ("💭", "Sometimes you worry too much about something…"),
        ("🌤️", "…and later you realize it wasn’t as bad as it felt.")
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color.themeBackground.ignoresSafeArea()
            
            // Breathing glow
            Circle()
                .fill(
                    RadialGradient(colors: [
                        Color.white.opacity(0.10),
                        Color.white.opacity(0.02)
                    ], center: .center, startRadius: 0, endRadius: 250)
                )
                .scaleEffect(breathing ? 1.06 : 0.94)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: breathing)
                .blur(radius: 60)
                .opacity(0.7)
            
            VStack(spacing: 36) {
                Spacer()
                
                // Scene
                storyScene(emoji: scenes[step].emoji, text: scenes[step].text)
                    .id(step)
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.4), value: step)
                
                // Progress bar (minimal white-gray style)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.themeDivider.opacity(0.3)) // background line
                            .frame(height: 5)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.themeText,
                                        Color.themeText.opacity(0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: .themeText.opacity(0.3), radius: 6)
                            .frame(width: geo.size.width * progress, height: 5)
                    }
                }
                .frame(height: 5)
                .padding(.horizontal, 60)
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
            
            // Fade overlay
            Color.themeBackground
                .ignoresSafeArea()
                .opacity(fadeOut ? 1 : 0)
                .animation(.easeInOut(duration: 0.8), value: fadeOut)
        }
        .onAppear {
            breathing = true
            startAutoProgress()
        }
    }
    
    private func storyScene(emoji: String, text: String) -> some View {
        VStack(spacing: 20) {
            Text(emoji)
                .font(.system(size: 80))
                .transition(.scale)
            
            Text(text)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.themeText)
                .padding(.horizontal)
        }
    }
    
    private func startAutoProgress() {
        progress = 0.0
        step = 0
        fadeOut = false
        
        let sceneDuration: Double = 2.5
        let totalScenes = scenes.count
        
        // Animate progress bar across full duration (5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: sceneDuration * Double(totalScenes))) {
                progress = 1.0
            }
        }
        
        // Switch to scene 2 after 2.5s
        DispatchQueue.main.asyncAfter(deadline: .now() + sceneDuration) {
            withAnimation(.easeInOut(duration: 0.4)) {
                step = 1
            }
        }
        
        // Fade out and dismiss after full duration (5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + (sceneDuration * Double(totalScenes))) {
            withAnimation(.easeInOut(duration: 0.8)) {
                fadeOut = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                hasSeenWorryIntro = true
                isPresented = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WorryIntroView(isPresented: .constant(true))
    }
}
