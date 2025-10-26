//
//  DataManager.swift
//  AnxietyTest&Companion
//
//  Created by Mehmet Ali Kısacık on 26.10.2025.
//

import CoreData
import Foundation

class DataManager {
    static let shared = DataManager()
    
    private init() {
        // Use the shared PersistenceController instead of creating our own container
    }
    
    var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    // MARK: - GAD-7 Entry Operations
    
    func saveGAD7Entry(score: Int, answers: [Int], date: Date = Date()) {
        let context = viewContext
        let entry = GAD7Entry(context: context)
        entry.id = UUID()
        entry.date = date  // Save actual time, not start of day
        entry.score = Int16(score)
        entry.answers = answers.map(String.init).joined(separator: ",")
        
        do {
            try context.save()
        } catch {
            print("Failed to save GAD-7 entry: \(error)")
        }
    }
    
    func fetchGAD7Entries(limit: Int? = nil) -> [GAD7Entry] {
        let request: NSFetchRequest<GAD7Entry> = GAD7Entry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GAD7Entry.date, ascending: false)]
        
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch GAD-7 entries: \(error)")
            return []
        }
    }
    
    func fetchGAD7Entries(from startDate: Date, to endDate: Date) -> [GAD7Entry] {
        let request: NSFetchRequest<GAD7Entry> = GAD7Entry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", 
                                      startDate.startOfDay() as NSDate, 
                                      endDate.startOfDay() as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GAD7Entry.date, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch GAD-7 entries by date range: \(error)")
            return []
        }
    }
    
    // MARK: - Mood Entry Operations
    
    func saveMoodEntry(mood: Int, date: Date = Date()) {
        let context = viewContext
        let normalizedDate = date.startOfDay()
        
        // Check if mood entry already exists for this date
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", normalizedDate as NSDate)
        
        do {
            let existingEntries = try context.fetch(request)
            
            if let existingEntry = existingEntries.first {
                // Update existing entry
                existingEntry.moodValue = Int16(mood)
            } else {
                // Create new entry
                let entry = MoodEntry(context: context)
                entry.id = UUID()
                entry.date = normalizedDate
                entry.moodValue = Int16(mood)
            }
            
            try context.save()
        } catch {
            print("Failed to save mood entry: \(error)")
        }
    }
    
    func fetchMoodEntries(from startDate: Date, to endDate: Date) -> [MoodEntry] {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", 
                                      startDate.startOfDay() as NSDate, 
                                      endDate.startOfDay() as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MoodEntry.date, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch mood entries: \(error)")
            return []
        }
    }
    
    func fetchMoodEntry(for date: Date) -> MoodEntry? {
        let request: NSFetchRequest<MoodEntry> = MoodEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date.startOfDay() as NSDate)
        request.fetchLimit = 1
        
        do {
            return try viewContext.fetch(request).first
        } catch {
            print("Failed to fetch mood entry for date: \(error)")
            return nil
        }
    }
    
    // MARK: - Journal Entry Operations
    
    func saveJournalEntry(prompt: String, content: String, activityType: String, date: Date = Date()) {
        let context = viewContext
        let entry = JournalEntry(context: context)
        entry.id = UUID()
        entry.date = date
        entry.prompt = prompt
        entry.content = content
        entry.activityType = activityType
        
        do {
            try context.save()
        } catch {
            print("Failed to save journal entry: \(error)")
        }
    }
    
    func fetchJournalEntries(limit: Int? = nil) -> [JournalEntry] {
        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntry.date, ascending: false)]
        
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch journal entries: \(error)")
            return []
        }
    }
    
    func fetchJournalEntries(by activityType: String) -> [JournalEntry] {
        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        request.predicate = NSPredicate(format: "activityType == %@", activityType)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntry.date, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch journal entries by type: \(error)")
            return []
        }
    }
    
    // MARK: - Calming Activity Completion Operations
    
    func saveActivityCompletion(activityTitle: String, duration: Int, completedAt: Date = Date()) {
        let context = viewContext
        let completion = CalmingActivityCompletion(context: context)
        completion.id = UUID()
        completion.activityTitle = activityTitle
        completion.completedAt = completedAt
        completion.duration = Int32(duration)
        
        do {
            try context.save()
        } catch {
            print("Failed to save activity completion: \(error)")
        }
    }
    
    func fetchActivityCompletions(limit: Int? = nil) -> [CalmingActivityCompletion] {
        let request: NSFetchRequest<CalmingActivityCompletion> = CalmingActivityCompletion.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CalmingActivityCompletion.completedAt, ascending: false)]
        
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch activity completions: \(error)")
            return []
        }
    }
    
    func fetchActivityCompletions(for activityTitle: String) -> [CalmingActivityCompletion] {
        let request: NSFetchRequest<CalmingActivityCompletion> = CalmingActivityCompletion.fetchRequest()
        request.predicate = NSPredicate(format: "activityTitle == %@", activityTitle)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CalmingActivityCompletion.completedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch activity completions by title: \(error)")
            return []
        }
    }
    
    // MARK: - Grounding Response Operations
    
    func saveGroundingResponse(seeResponses: [String], hearResponses: [String], touchResponses: [String], smellResponses: [String], tasteResponse: String, date: Date = Date()) {
        let context = viewContext
        let response = GroundingResponse(context: context)
        response.id = UUID()
        response.date = date
        response.seeResponses = seeResponses.joined(separator: ",")
        response.hearResponses = hearResponses.joined(separator: ",")
        response.touchResponses = touchResponses.joined(separator: ",")
        response.smellResponses = smellResponses.joined(separator: ",")
        response.tasteResponse = tasteResponse
        
        do {
            try context.save()
        } catch {
            print("Failed to save grounding response: \(error)")
        }
    }
    
    func fetchGroundingResponses(limit: Int? = nil) -> [GroundingResponse] {
        let request: NSFetchRequest<GroundingResponse> = GroundingResponse.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GroundingResponse.date, ascending: false)]
        
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch grounding responses: \(error)")
            return []
        }
    }
    
    // MARK: - Delete Operations
    
    func deleteEntry(_ entry: NSManagedObject) {
        viewContext.delete(entry)
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete entry: \(error)")
        }
    }
    
    // MARK: - Migration from AppStorage
    
    func migrateFromAppStorage() {
        let hasMigrated = UserDefaults.standard.bool(forKey: "hasMigratedToCoreData")
        guard !hasMigrated else { return }
        
        // Migrate last GAD-7 score if it exists
        let hasCompletedTest = UserDefaults.standard.bool(forKey: "hasCompletedTest")
        if hasCompletedTest {
            let lastScore = UserDefaults.standard.integer(forKey: "lastGAD7Score")
            let timestamp = UserDefaults.standard.double(forKey: "lastGAD7DateTimestamp")
            let lastDate = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : (UserDefaults.standard.object(forKey: "lastGAD7Date") as? Date ?? Date())
            
            // Create a basic answers array (all zeros) for migration
            let defaultAnswers = Array(repeating: 0, count: 7)
            saveGAD7Entry(score: lastScore, answers: defaultAnswers, date: lastDate)
        }
        
        // Mark migration as complete
        UserDefaults.standard.set(true, forKey: "hasMigratedToCoreData")
    }
}
