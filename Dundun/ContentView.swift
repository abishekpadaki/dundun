//
//  ContentView.swift
//  Dundun
//
//  Created by Abishek Padaki on 8/16/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StreakViewModel()
    @State private var newStreakTitle = ""
    @State private var showingAddStreak = false
    @State private var currentDate = Date()
    @State private var activeAlert: ActiveAlert?
    
    enum ActiveAlert: Identifiable {
        case delete(Streak)
        case reset(Streak)
        
        var id: String {
            switch self {
            case .delete(let streak):
                return "delete_\(streak.id)"
            case .reset(let streak):
                return "reset_\(streak.id)"
            }
        }
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.streaks) { streak in
                    StreakRowView(streak: streak, viewModel: viewModel)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                viewModel.completeStreak(streak)
                            } label: {
                                Label("Done", systemImage: "checkmark.circle.fill")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                viewModel.undoCompleteStreak(streak)
                            } label: {
                                Label("Not Done", systemImage: "xmark.circle.fill")
                            }
                            .tint(.red)
                        }
                        .contextMenu {
                            Button(action: {
                                activeAlert = .delete(streak)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button(action: {
                                activeAlert = .reset(streak)
                            }) {
                                Label("Reset Streak", systemImage: "arrow.counterclockwise")
                            }
                        }
                }
            }
            .navigationTitle("Dundun")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddStreak = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddStreak) {
                AddStreakView(viewModel: viewModel, isPresented: $showingAddStreak)
            }
            .alert(item: $activeAlert) { alert in
                switch alert {
                case .delete(let streak):
                    return Alert(
                        title: Text("Delete Streak"),
                        message: Text("Are you sure you want to delete this streak?"),
                        primaryButton: .destructive(Text("Delete")) {
                            viewModel.deleteStreak(streak)
                        },
                        secondaryButton: .cancel()
                    )
                case .reset(let streak):
                    return Alert(
                        title: Text("Reset Streak"),
                        message: Text("Are you sure you want to reset this streak to zero?"),
                        primaryButton: .destructive(Text("Reset")) {
                            viewModel.resetStreak(streak)
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .onReceive(timer) { _ in
            let newDate = Date()
            if !Calendar.current.isDate(currentDate, inSameDayAs: newDate) {
                currentDate = newDate
                viewModel.objectWillChange.send()
            }
        }
    }
}

struct StreakRowView: View {
    let streak: Streak
    @ObservedObject var viewModel: StreakViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(streak.title)
                    .font(.headline)
                Text("Current streak: \(streak.count) days")
                    .font(.subheadline)
                Text("Longest streak: \(streak.longestStreak) days")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if viewModel.isStreakCompletedToday(streak) {
                Text("👍")
                    .font(.title)
            } else {
                Button(action: {
                    viewModel.completeStreak(streak)
                }) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.title)
                }
            }
        }
    }
}

struct AddStreakView: View {
    @ObservedObject var viewModel: StreakViewModel
    @Binding var isPresented: Bool
    @State private var title = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Streak Title", text: $title)
            }
            .navigationTitle("Add New Streak")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    viewModel.addStreak(title: title)
                    isPresented = false
                }
                .disabled(title.isEmpty)
            )
        }
    }
}
