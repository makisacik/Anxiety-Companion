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
    
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "AnxietyTest_Companion")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - GAD-7 Entry Operations
    
    func saveGAD7Entry(score: Int, answers: [Int], date: Date = Date()) {
        let context = viewContext
        let entry = GAD7Entry(context: context)
        entry.id = UUID()
        entry.date = date.startOfDay()
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
            let lastDate = UserDefaults.standard.object(forKey: "lastGAD7Date") as? Date ?? Date()
            
            // Create a basic answers array (all zeros) for migration
            let defaultAnswers = Array(repeating: 0, count: 7)
            saveGAD7Entry(score: lastScore, answers: defaultAnswers, date: lastDate)
        }
        
        // Mark migration as complete
        UserDefaults.standard.set(true, forKey: "hasMigratedToCoreData")
    }
}
