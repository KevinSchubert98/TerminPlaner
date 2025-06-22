//
//  Termin.swift
//  Termin Planer
//
//  Created by Kevin Schubert on 22.06.25.
//

import Foundation

enum Recurrence: String, Codable, CaseIterable, Identifiable {
    case none = "Keine"
    case daily = "Täglich"
    case weekly = "Wöchentlich"
    case monthly = "Monatlich"
    
    var id: String { rawValue }
}

struct Termin: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var recurrence: Recurrence = .none
    var reminderOffsets: [TimeInterval] = []
    var isDone: Bool = false // ✅ Neu hinzugefügt
    var kategorie: Kategorie = .sonstiges
}
