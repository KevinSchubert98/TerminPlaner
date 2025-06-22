//
//  KalenderView.swift
//  Termin Planer
//
//  Created by Kevin Schubert on 22.06.25.
//

import SwiftUI

enum Ansicht: String, CaseIterable, Identifiable {
    case monat = "Monat"
    case woche = "Woche"
    case tag = "Tag"
    
    var id: String { rawValue }
}

struct KalenderView: View {
    @ObservedObject var viewModel: TerminViewModel
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date? = nil
    @State private var searchText: String = ""
    @State private var selectedKategorie: Kategorie? = nil
    @State private var aktuelleAnsicht: Ansicht = .monat
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var filteredTermine: [Termin] {
        viewModel.termine.filter { termin in
            (selectedKategorie == nil || termin.kategorie == selectedKategorie) &&
            (searchText.isEmpty || termin.title.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Ansicht", selection: $aktuelleAnsicht) {
                    ForEach(Ansicht.allCases) { ansicht in
                        Text(ansicht.rawValue).tag(ansicht)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: { selectedKategorie = nil }) {
                            Text("Alle")
                                .padding(8)
                                .background(selectedKategorie == nil ? Color.accentColor : Color.clear)
                                .foregroundColor(selectedKategorie == nil ? .white : .primary)
                                .cornerRadius(8)
                        }
                        
                        ForEach(Kategorie.allCases) { kategorie in
                            Button(action: { selectedKategorie = kategorie }) {
                                Text(kategorie.rawValue)
                                    .padding(8)
                                    .background(selectedKategorie == kategorie ? kategorie.farbe : Color.clear)
                                    .foregroundColor(selectedKategorie == kategorie ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Suchfeld iOS15+:
                if #available(iOS 15.0, *) {
                    ListView()
                        .searchable(text: $searchText, prompt: "Termine suchen")
                } else {
                    VStack {
                        TextField("Suchen...", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        ListView()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("TerminPlaner")
        }
    }
    
    @ViewBuilder
    func ListView() -> some View {
        switch aktuelleAnsicht {
        case .monat:
            MonatsAnsicht()
        case .woche:
            WochenAnsicht()
        case .tag:
            TagesAnsicht()
        }
    }
    
    // MARK: Monatsansicht (Kalender-Gitter)
    @ViewBuilder
    func MonatsAnsicht() -> some View {
        VStack {
            // Monatsnavigation
            HStack {
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(from: currentMonth))
                    .font(.headline)
                Spacer()
                Button(action: {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Wochentage
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(weekDaySymbols(), id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            // Kalendertage
            let days = generateDaysInMonth()
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                    dayView(date: date)
                        .onTapGesture {
                            if let date = date, isInCurrentMonth(date) {
                                selectedDate = date
                                aktuelleAnsicht = .tag
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: Wochenansicht
    @ViewBuilder
    func WochenAnsicht() -> some View {
        let heute = Date()
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: heute)?.start ?? heute
        let endOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: heute)?.end ?? heute
        
        let termineInWoche = filteredTermine.filter {
            $0.date >= startOfWeek && $0.date < endOfWeek
        }.sorted(by: { $0.date < $1.date })
        
        List {
            ForEach(termineInWoche) { termin in
                VStack(alignment: .leading) {
                    Text(termin.title)
                        .font(.headline)
                    Text(termin.date, style: .date)
                    Text(termin.date, style: .time)
                    Text(termin.kategorie.rawValue)
                        .font(.caption)
                        .foregroundColor(termin.kategorie.farbe)
                }
            }
        }
    }
    
    // MARK: Tagesansicht
    @ViewBuilder
    func TagesAnsicht() -> some View {
        if let selectedDate = selectedDate {
            let termineAmTag = filteredTermine.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            
            List {
                if termineAmTag.isEmpty {
                    Text("Keine Termine an diesem Tag")
                        .foregroundColor(.gray)
                } else {
                    ForEach(termineAmTag) { termin in
                        VStack(alignment: .leading) {
                            Text(termin.title).font(.headline)
                            Text(termin.date, style: .time)
                            Text(termin.kategorie.rawValue)
                                .font(.caption)
                                .foregroundColor(termin.kategorie.farbe)
                        }
                    }
                }
            }
        } else {
            Text("Bitte einen Tag auswählen")
                .padding()
        }
    }
    
    // MARK: Hilfsfunktionen
    
    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    
    func weekDaySymbols() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
    
    func isInCurrentMonth(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    func generateDaysInMonth() -> [Date?] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth) else { return [] }
        var days: [Date?] = []
        
        let firstWeekday = Calendar.current.component(.weekday, from: monthInterval.start)
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        let range = Calendar.current.range(of: .day, in: .month, for: currentMonth)!
        for day in range {
            if let date = Calendar.current.date(bySetting: .day, value: day, of: currentMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    @ViewBuilder
    func dayView(date: Date?) -> some View {
        if let date = date {
            VStack(spacing: 4) {
                Text("\(Calendar.current.component(.day, from: date))")
                    .foregroundColor(isInCurrentMonth(date) ? .primary : .gray)
                    .fontWeight(selectedDate != nil && Calendar.current.isDate(date, inSameDayAs: selectedDate!) ? .bold : .regular)
                    .frame(maxWidth: .infinity)
                
                if !filteredTermine.filter({ Calendar.current.isDate($0.date, inSameDayAs: date) }).isEmpty {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(8)
            .background(selectedDate != nil && Calendar.current.isDate(date, inSameDayAs: selectedDate!) ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        } else {
            Rectangle()
                .fill(Color.clear)
                .frame(height: 40)
        }
    }
}

struct KalenderView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = TerminViewModel()
        vm.termine = [
            Termin(title: "Meeting", date: Date(), kategorie: .arbeit),
            Termin(title: "Geburtstag", date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, kategorie: .privat),
            Termin(title: "Familienfest", date: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, kategorie: .familie)
        ]
        return KalenderView(viewModel: vm)
    }
}
