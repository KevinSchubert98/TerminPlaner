//
//  ContentView.swift
//  Termin Planer
//
//  Created by Kevin Schubert on 22.06.25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject var viewModel = TerminViewModel()
    @State private var showingAddTermin = false
    @State private var showCalendar = false
    
    var body: some View {
        NavigationView {
            VStack {
                if showCalendar {
                    KalenderView(viewModel: viewModel)
                } else {
                    List {
                        if viewModel.upcomingTermine().isEmpty {
                            Text("Keine Termine")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.upcomingTermine()) { termin in
                                VStack(alignment: .leading) {
                                    Text(termin.title)
                                        .font(.headline)
                                    Text(termin.date, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    if termin.recurrence != .none {
                                        Text("Wiederholt: \(termin.recurrence.rawValue)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    if !termin.reminderOffsets.isEmpty {
                                        Text("Erinnerungen: " + termin.reminderOffsets.map { reminderText(for: $0) }.joined(separator: ", "))
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .onDelete(perform: viewModel.removeTermine)
                        }
                    }
                }
            }
            .navigationTitle("TerminPlaner")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTermin = true }) {
                        Image(systemName: "plus")
                    }
                    Button(action: { showCalendar.toggle() }) {
                        Image(systemName: showCalendar ? "list.bullet" : "calendar")
                    }
                }
            }
            .sheet(isPresented: $showingAddTermin) {
                AddTerminView(viewModel: viewModel)
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
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
