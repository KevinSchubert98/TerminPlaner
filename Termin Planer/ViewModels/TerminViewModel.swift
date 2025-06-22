//
//  TerminViewModel.swift
//  Termin Planer
//
//  Created by Kevin Schubert on 22.06.25.
//

import Foundation
import UserNotifications

class TerminViewModel: ObservableObject {
    @Published var termine: [Termin] = [] {
        didSet {
            saveTermine()
        }
    }
    
    private let saveKey = "termine_save_key"
    
    init() {
        loadTermine()
    }
    
    func addTermin(title: String, date: Date, recurrence: Recurrence = .none, reminderOffsets: [TimeInterval] = [], kategorie: Kategorie = .sonstiges) {
        let neuerTermin = Termin(title: title, date: date, recurrence: recurrence, reminderOffsets: reminderOffsets, isDone: false, kategorie: kategorie)
        termine.append(neuerTermin)
        scheduleNotifications(for: neuerTermin)
    }
    
    func removeTermine(at offsets: IndexSet) {
        for index in offsets {
            removeNotification(for: termine[index])
        }
        termine.remove(atOffsets: offsets)
    }
    
    func toggleDone(for termin: Termin) {
        if let index = termine.firstIndex(where: { $0.id == termin.id }) {
            termine[index].isDone.toggle()
        }
    }
    
    private func saveTermine() {
        if let encoded = try? JSONEncoder().encode(termine) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadTermine() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Termin].self, from: savedData) {
            termine = decoded
        }
    }
    
    func upcomingTermine() -> [Termin] {
        let now = Date()
        var results: [Termin] = []
        
        for termin in termine {
            if termin.date >= now {
                results.append(termin)
            } else if termin.recurrence != .none {
                var nextDate = termin.date
                while nextDate < now {
                    switch termin.recurrence {
                    case .daily:
                        nextDate = Calendar.current.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
                    case .weekly:
                        nextDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: nextDate) ?? nextDate
                    case .monthly:
                        nextDate = Calendar.current.date(byAdding: .month, value: 1, to: nextDate) ?? nextDate
                    default:
                        break
                    }
                }
                var nextTermin = termin
                nextTermin.date = nextDate
                results.append(nextTermin)
            }
        }
        
        return results.sorted { $0.date < $1.date }
    }
    
    // MARK: - Notifications
    
    func scheduleNotifications(for termin: Termin) {
        removeNotification(for: termin)
        
        for offset in termin.reminderOffsets {
            let content = UNMutableNotificationContent()
            content.title = "Erinnerung"
            content.body = "Termin: \(termin.title)"
            content.sound = .default
            
            let reminderDate = termin.date.addingTimeInterval(-offset)
            if reminderDate > Date() {
                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                let identifier = termin.id.uuidString + "_\(Int(offset))"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    func removeNotification(for termin: Termin) {
        let ids = termin.reminderOffsets.map { termin.id.uuidString + "_\(Int($0))" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
