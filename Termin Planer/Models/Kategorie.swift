//
//  Kategorie.swift
//  Termin Planer
//
//  Created by Kevin Schubert on 22.06.25.
//

import Foundation
import SwiftUICore

enum Kategorie: String, Codable, CaseIterable, Identifiable {
    case arbeit = "Arbeit"
    case privat = "Privat"
    case gesundheit = "Gesundheit"
    case sport = "Sport"
    case sonstiges = "Sonstiges"
    case familie = "Familie"
    case alltag = "Alltag"
    
    var id: String { rawValue }
    
    var farbe: Color {
        switch self {
        case .arbeit: return .blue
        case .privat: return .orange
        case .gesundheit: return .green
        case .sport: return .red
        case .sonstiges: return .gray
        case .familie: return .pink
        case .alltag: return.mint
        }
    }
}
