//
//  FreeTrialView.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 28.10.2025.
//

import SwiftUI

struct FreeTrialView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Top close button
            HStack {
                Button(action: onContinue) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.themeText.opacity(0.6))
                        .frame(width: 44, height: 44)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Spacer()
            
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 10) {
                        Text(String(localized: "freetrial_title"))
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.themeText)
                        .multilineTextAlignment(.center)
                    
                        Text(String(localized: "freetrial_subtitle"))
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.themeText.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                // Timeline Card
                VStack(alignment: .leading, spacing: 0) {
                    // Today Section
                    HStack(alignment: .top, spacing: 15) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.themeCard)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.themeText)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 5) {
                                Text(String(localized: "freetrial_today_title"))
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.themeText)
                            
                                Text(String(localized: "freetrial_today_message"))
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 25)
                    
                    // Day 5 Reminder Section
                    HStack(alignment: .top, spacing: 15) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.themeCard)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.themeText)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 5) {
                                Text(String(localized: "freetrial_day5_title"))
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.themeText)
                            
                                Text(String(localized: "freetrial_day5_message"))
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 25)
                    
                    // Day 7+ Section
                    HStack(alignment: .top, spacing: 15) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.themeCard)
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "diamond.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.themeText)
                        }
                        
                        // Content
                        VStack(alignment: .leading, spacing: 5) {
                                Text(String(localized: "freetrial_after7_title"))
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(.themeText)
                            
                                Text(String(localized: "freetrial_after7_message"))
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.themeText.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.themeBackgroundPure)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
                )
                .padding(.horizontal, 30)
                
                // Pricing Text
                    Text(String(localized: "freetrial_pricing"))
                    .font(.system(.footnote, design: .rounded))
                    .foregroundColor(.themeText.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            // Start Free Trial Button
            Button(action: onContinue) {
                    Text(String(localized: "freetrial_start_button"))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.themeCard)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            
            // Footer Links
            HStack(spacing: 30) {
                    Button(String(localized: "freetrial_terms")) {
                    // Handle terms action
                }
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.themeText.opacity(0.5))
                
                    Button(String(localized: "freetrial_privacy")) {
                    // Handle privacy action
                }
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.themeText.opacity(0.5))
                
                    Button(String(localized: "freetrial_restore")) {
                    // Handle restore action
                }
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.themeText.opacity(0.5))
            }
            .padding(.bottom, 30)
        }
        .background(Color.themeBackground)
    }
}

#Preview {
    FreeTrialView(onContinue: {
        print("Continue tapped")
    })
}
