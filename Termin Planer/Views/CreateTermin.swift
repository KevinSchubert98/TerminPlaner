//
//  CreateTermin.swift
//  Termin Planer
//
//  Created by Kevin Schubert on 22.06.25.
//

import SwiftUI

struct TerminErstellenView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TerminViewModel

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var recurrence: Recurrence = .none
    @State private var reminderOffset: TimeInterval = 0
    @State private var kategorie: Kategorie = .sonstiges

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Titel")) {
                    TextField("Titel eingeben", text: $title)
                }

                Section(header: Text("Datum & Uhrzeit")) {
                    DatePicker("Terminzeit", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Kategorie")) {
                    Picker("Kategorie", selection: $kategorie) {
                        ForEach(Kategorie.allCases) { kategorie in
                            Label(kategorie.rawValue, systemImage: "circle.fill")
                                .foregroundColor(kategorie.farbe)
                                .tag(kategorie)
                        }
                    }
                }

                Section(header: Text("Wiederholung")) {
                    Picker("Wiederholen", selection: $recurrence) {
                        ForEach(Recurrence.allCases) { recurrence in
                            Text(recurrence.rawValue).tag(recurrence)
                        }
                    }
                }

                Section(header: Text("Erinnerung")) {
                    Picker("Erinnerung vor Termin", selection: $reminderOffset) {
                        Text("Keine").tag(0.0)
                        Text("5 Minuten").tag(300.0)
                        Text("15 Minuten").tag(900.0)
                        Text("1 Stunde").tag(3600.0)
                    }
                }

                Button("Speichern") {
                    let reminderOffsets = reminderOffset > 0 ? [reminderOffset] : []
                    viewModel.addTermin(title: title, date: date, recurrence: recurrence, reminderOffsets: reminderOffsets, kategorie: kategorie)
                    dismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .navigationTitle("Neuer Termin")
            .navigationBarItems(leading: Button("Abbrechen") {
                dismiss()
            })
        }
    }
}
