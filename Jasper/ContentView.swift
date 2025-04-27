//
//  ContentView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 8/7/24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.modelContext) var modelContext
    
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    @State private var appState = AppState()
    
    @State private var selectedServer: JamfProServer?
    @State private var selectedSearch: Search?
    
    @State private var showSettingsSheet = false
    @State private var showAddServerSheet = false
    @State private var showAddSearchSheet = false
    
    @Query var servers: [JamfProServer]
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ServerSelectionView(selectedServer: $selectedServer)
                .navigationTitle("Server List")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationSplitViewStyle(.balanced)
                .overlay(content: {
                    if servers.isEmpty {
                        ContentUnavailableView("No saved servers", image: "custom.server.add")
                    }
                })
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Settings", systemImage: "gear") {
                            showSettingsSheet.toggle()
                        }
                        .tint(colorScheme == .light ? .blue : .white)
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showAddServerSheet = true
                        } label: {
                            Label("Add server", image: "custom.server.add")
                        }
                        .tint(colorScheme == .light ? .blue : .white)
                    }
                }
        } content: {
            if let selectedServer {
                ServerView(server: selectedServer, selectedSearch: $selectedSearch)
                    .navigationTitle(selectedServer.hostname)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(ServerThemeGradient(baseColor: appState.themeColor), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
                    .scrollContentBackground(.hidden)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add search", systemImage: "plus") {
                                showAddSearchSheet = true
                            }
                        }
                    }
            } else if !servers.isEmpty {
                ContentUnavailableView("Select a Server", systemImage: "server.rack")
                    .toolbarBackground(.visible, for: .navigationBar)
            } else {
                Spacer()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
        } detail: {
            NavigationStack {
                if let selectedServer, let selectedSearch {
                    switch selectedSearch.searchType {
                    case .computer:
                        ComputerSearchResultsView(server: selectedServer, search: selectedSearch)
                            .id(selectedSearch.id)
                    case .mobileDevice:
                        MobileDeviceSearchResultsView(server: selectedServer, search: selectedSearch)
                            .id(selectedSearch.id)
                    }
                } else if selectedServer != nil && selectedSearch == nil {
                    ZStack {
                        appState.themeColor
                            .opacity(colorScheme == .light ? 0.25 : 0.5)
                            .edgesIgnoringSafeArea(.all)
                        
                        ContentUnavailableView("Select or Create a Search", systemImage: "magnifyingglass.circle")
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(ServerThemeGradient(baseColor: appState.themeColor), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                } else {
                    Spacer()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
            }
        }
        .environment(appState)
        .sheet(isPresented: $showSettingsSheet, content: {
            SettingsView()
                .environment(appState)
        })
        .sheet(isPresented: $showAddServerSheet) {
            AddServerView(selectedServer: $selectedServer)
                .environment(appState)
        }
        .sheet(isPresented: $showAddSearchSheet) {
            if let selectedServer {
                AddSearchView(server: selectedServer)
                    .environment(appState)
            } else {
                ContentUnavailableView("Select a Server", systemImage: "server.rack")
            }
        }
        .onAppear() {
            appState.reportedHorizontalSizeClass = horizontalSizeClass
            print("APP REPORTED SIZE CLASS: \(appState.reportedHorizontalSizeClass)")
        }
        .onChange(of: horizontalSizeClass) {
            appState.reportedHorizontalSizeClass = horizontalSizeClass
            print("APP REPORTED SIZE CLASS: \(appState.reportedHorizontalSizeClass)")
        }
        .onChange(of: selectedServer) {
            appState.logger.info("SELECTED SERVER: CHANGED \(selectedServer?.hostname ?? "none")")
            withAnimation {
                if let selectedServer {
                    appState.setThemeColor(selectedServer.themeColorRGB)
                }
                selectedSearch = nil
                columnVisibility = selectedServer == nil ? .all : .doubleColumn
            }
        }
        .onChange(of: selectedSearch) { oldValue, newValue in
            appState.logger.info("SELECTED SEARCH: \(oldValue?.name ?? "none") -> \(newValue?.name ?? "none")")
            columnVisibility = .automatic
        }
        #if DEBUG
        .onAppear {
            appState.logger.debug("\(modelContext.sqliteCommand)")
        }
        #endif
    }
}

enum DetailViewSelection {
    case empty
    case noSearch
    case computersSearch
    case mobileDevicesSearch
    case computer
    case mobileDevice
}

#if DEBUG
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JamfProServer.self, configurations: config)
//    container.mainContext.insert(JamfProServer.preview)

    return ContentView()
        .modelContainer(container)
}
#endif
