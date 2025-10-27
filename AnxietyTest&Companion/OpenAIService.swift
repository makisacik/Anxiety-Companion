//
//  OpenAIService.swift
//  AnxietyTest&Companion
//
//  Service for generating personalized Calm Journey reports using GPT-4o-mini
//

import Foundation
import Combine

struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

struct OpenAIRequest: Codable {
    let model: String
    let messages: [Message]
    let temperature: Double
    let maxTokens: Int
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

class OpenAIService: ObservableObject {
    static let shared = OpenAIService()
    
    @Published var isGenerating = false
    
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let apiKey = Config.openAIAPIKey
    
    private init() {}
    
    func generateCalmReport(reflections: [String]) async throws -> String {
        print("Debug: OpenAI generateCalmReport called with \(reflections.count) reflections")
        
        guard !reflections.isEmpty else {
            print("Debug: No reflections provided")
            throw OpenAIError.noReflections
        }
        
        await MainActor.run {
            isGenerating = true
        }
        
        defer {
            Task { @MainActor in
                isGenerating = false
            }
        }
        
        let reflectionsText = reflections.map { "• " + $0 }.joined(separator: "\n")
        print("Debug: Reflections text length: \(reflectionsText.count) characters")
        
        let systemPrompt = """
        You are a compassionate mental health coach who writes personalized reflection reports.
        """
        
        let userPrompt = """
        You are a compassionate mental health companion trained in emotional reflection and anxiety recovery support.
        Your task is to create a Personalized Calm Report for a user who has completed a guided journey through anxiety management exercises.

        The app's journey helps users understand anxiety, reframe thoughts, and build calm habits. Each exercise involves journaling prompts, breathing practices, and mindfulness reflections.

        The following text represents the user's written reflections and prompt answers collected across the journey. Use them to generate a warm, personalized summary that highlights their emotional growth and patterns.

        🪞 Input Data:
        \(reflectionsText)

        Each bullet or paragraph in the reflections comes from a journaling exercise (e.g., identifying triggers, reframing thoughts, reflecting on habits, or values). The data may include short phrases, notes, or complete sentences. Assume these were written by one user over time.

        🌱 Your Task:

        Write a Personalized Calm Journey Report using the reflections above.
        The tone must be warm, supportive, and human — like a therapist summarizing a client's progress with empathy.
        Avoid clinical or diagnostic language. Use second person ("you") throughout.

        Format your response with clear section headers:

        1. Introduction

        A short, kind overview. Acknowledge their commitment, progress, and courage in facing anxiety.

        2. Emotional Themes

        Identify recurring feelings, thoughts, or patterns visible in their reflections. Highlight positive shifts (e.g., "You've started noticing calm moments…").

        3. Strengths You've Shown

        Mention emotional strengths, coping skills, or mindset changes that stand out. Examples: awareness, honesty, self-kindness, consistency.

        4. Areas Still in Progress

        Offer gentle encouragement about where they can continue growing. Avoid judgment — instead, use compassionate reframe ("You're learning to trust calm even when fear reappears").

        5. Your Calm Growth Summary

        Write a brief narrative paragraph summarizing their journey — from initial awareness to self-compassion and calm action. Make it feel like an evolution story.

        6. Encouragement Forward

        Close with an uplifting reflection that leaves the user hopeful and proud ("You've learned to breathe through fear and speak kindly to yourself. Keep practicing — peace is now part of you.")

        ✨ Style & Constraints:

        Keep tone: gentle, encouraging, wise.

        Use short paragraphs (2–3 sentences each).

        Avoid "diagnosing" or "labeling."

        Avoid repeating exact user sentences. Summarize and interpret insightfully.

        The report should sound human-written, not robotic or analytical.

        Max 600 words total.

        🔒 Note:

        Assume all reflections are stored securely and are used solely for generating this one-time report.
        Do not include any privacy disclaimers or mention "AI" — write naturally as if speaking directly to the user.
        """
        
        let request = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                OpenAIRequest.Message(role: "system", content: systemPrompt),
                OpenAIRequest.Message(role: "user", content: userPrompt)
            ],
            temperature: 0.7,
            maxTokens: 800
        )
        
        return try await performRequest(request)
    }
    
    private func performRequest(_ request: OpenAIRequest) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw OpenAIError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Debug: Invalid response type")
            throw OpenAIError.invalidResponse
        }
        
        print("Debug: HTTP Status Code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                print("Debug: Invalid API key")
                throw OpenAIError.invalidAPIKey
            } else if httpResponse.statusCode == 429 {
                print("Debug: Rate limited")
                throw OpenAIError.rateLimited
            } else {
                print("Debug: Server error: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Debug: Error response: \(responseString)")
                }
                throw OpenAIError.serverError(httpResponse.statusCode)
            }
        }
        
        do {
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            print("Debug: OpenAI response decoded successfully")
            print("Debug: Number of choices: \(openAIResponse.choices.count)")
            
            guard let firstChoice = openAIResponse.choices.first else {
                print("Debug: No choices in response")
                throw OpenAIError.noResponse
            }
            
            let content = firstChoice.message.content
            print("Debug: Generated content length: \(content.count) characters")
            print("Debug: First 200 characters: \(String(content.prefix(200)))")
            
            return content
        } catch {
            print("Debug: Decoding error: \(error)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Debug: Raw response: \(responseString)")
            }
            throw OpenAIError.decodingError
        }
    }
}

enum OpenAIError: LocalizedError {
    case noReflections
    case invalidURL
    case encodingError
    case invalidResponse
    case invalidAPIKey
    case rateLimited
    case serverError(Int)
    case noResponse
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .noReflections:
            return "No reflections available to generate report"
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError:
            return "Failed to encode request"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidAPIKey:
            return "Invalid API key"
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .serverError(let code):
            return "Server error: \(code)"
        case .noResponse:
            return "No response from AI service"
        case .decodingError:
            return "Failed to decode response"
        }
    }
}
