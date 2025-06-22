//
//  Untitled.swift
//  Termin Planer
//
//  Created by Kevin Schubert on 22.06.25.
//

import SwiftUI

struct AddTerminView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TerminViewModel
    
    @State private var titel = ""
    @State private var datum = Date()
    @State private var recurrence: Recurrence = .none
    @State private var selectedKategorie: Kategorie = .alltag
    
    let reminderOptions: [TimeInterval] = [300, 900, 3600, 86400] // 5min, 15min, 1h, 1 Tag
    @State private var selectedReminders: Set<TimeInterval> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Termin")) {
                    TextField("Titel", text: $titel)
                    DatePicker("Datum & Zeit", selection: $datum)
                }
                
                Section(header: Text("Kategorie")) {
                    Picker("Kategorie", selection: $selectedKategorie) {
                        ForEach(Kategorie.allCases) { kategorie in
                            Text(kategorie.rawValue).tag(kategorie)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Wiederholung")) {
                    Picker("Wiederholen", selection: $recurrence) {
                        ForEach(Recurrence.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Erinnerungen")) {
                    ForEach(reminderOptions, id: \.self) { offset in
                        Button(action: {
                            if selectedReminders.contains(offset) {
                                selectedReminders.remove(offset)
                            } else {
                                selectedReminders.insert(offset)
                            }
                        }) {
                            HStack {
                                Text(reminderText(for: offset))
                                Spacer()
                                if selectedReminders.contains(offset) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Neuen Termin")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        if !titel.isEmpty {
                            viewModel.addTermin(title: titel, date: datum, recurrence: recurrence, reminderOffsets: Array(selectedReminders), kategorie: selectedKategorie)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(titel.isEmpty)
                }
            }
        }
    }
    
    func reminderText(for offset: TimeInterval) -> String {
        if offset >= 86400 {
            return "\(Int(offset/86400)) Tag(e) vorher"
        } else if offset >= 3600 {
            return "\(Int(offset/3600)) Stunde(n) vorher"
        } else if offset >= 60 {
            return "\(Int(offset/60)) Minute(n) vorher"
        }
        return "\(Int(offset)) Sekunde(n) vorher"
    }
}
