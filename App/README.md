# 📅 Terminplaner App (SwiftUI)

Eine moderne, lokale Terminplaner-App für iOS mit Erinnerungsfunktion, Wiederholungen und Kategorien – erstellt mit SwiftUI und UserNotifications.

---

## 🚀 Funktionen

- ✅ **Termin erstellen** mit Titel, Datum, Wiederholung und Kategorie  
- ⏰ **Erinnerungen** vor dem Termin (5 Min, 15 Min, 1 Std, 1 Tag)  
- 🔁 **Wiederkehrende Termine** (täglich, wöchentlich, monatlich)  
- 🎨 **Kategorien** zur besseren Organisation (Arbeit, Familie, Sport, …)  
- 🔕 **Lokale Benachrichtigungen** durch iOS Notification Center  
- 🧠 **Statusverwaltung:** Termine als "erledigt" markieren  
- 💾 **Persistenz** via `UserDefaults` (Daten bleiben erhalten)  

---

## 🖼️ Screenshots

| Terminliste | Neuer Termin | Erinnerungen & Kategorien |
|-------------|--------------|---------------------------|
| ![Terminliste](Preview Assets/screenshot1) | ![Neuer Termin](Preview Asstes/screenshot2) | ![Erinnerungen](Preview Asstes/screenshot3) |



---

## 📦 Projektstruktur

Terminplaner/
├── Models/
│ ├── Termin.swift
│ ├── Kategorie.swift
│ └── Recurrence.swift
├── ViewModels/
│ └── TerminViewModel.swift
├── Views/
│ └── AddTerminView.swift
├── Assets/
├── Info.plist
└── README.md


## 📌 Noch geplant

- [ ] iCloud-Sync der Termine  
- [ ] Termin-Benachrichtigungen wiederholend planen  
- [ ] UI-Optimierung für iPad  
- [ ] Dunkelmodus-Unterstützung  
