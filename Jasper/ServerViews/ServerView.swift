//
//  JamfProServerView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 8/8/24.
//

import SwiftUI

struct ServerView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Environment(AppState.self) var appState
    
    @State private var apiTask: Task<Void, Never>?
    
    var server: JamfProServer
    @Binding var selectedSearch: Search?
    
    @State private var showCopied = false
    
    @State private var jamfProVersion: String = ""
    @State private var jamfProInventoryInfo: Components.Schemas.InventoryInformation?
    
    @State private var showingNotificationsSection = false
    @State private var jamfProNotifications = [Components.Schemas.NotificationV1]()
    
    @State private var quickSearchText = ""
    @State private var quickSearchType: SearchType = .computer
    
    var body: some View {
        ZStack {
            appState.themeColor
                .opacity(colorScheme == .light ? 0.25 : 0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                List(selection: $selectedSearch) {
                    Section(isExpanded: $showingNotificationsSection) {
                        ForEach(jamfProNotifications, id: \._type) { notification in
                            NotificationItem(notification: notification)
                        }
                    } header: {
                        HStack {
                            Text("Notifications")
                            if !jamfProNotifications.isEmpty {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(.yellow)
                                Image(systemName: showingNotificationsSection ? "chevron.down" : "chevron.up")
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                showingNotificationsSection.toggle()
                            }
                        }
                    }
                    .disabled(jamfProNotifications.isEmpty)
                    
                    Section("Quick Search") {
                        HStack {
                            Button {
                                withAnimation {
                                    switch quickSearchType {
                                    case .computer:
                                        quickSearchType = .mobileDevice
                                    case .mobileDevice:
                                        quickSearchType = .computer
                                    }
                                }
                            } label: {
                                switch quickSearchType {
                                case .computer:
                                    Image(systemName: "desktopcomputer.and.macbook")
                                case .mobileDevice:
                                    Image(systemName: "ipad.landscape.and.iphone")
                                }
                            }
                            .foregroundStyle(.secondary)
                            
                            TextField("Search...", text: $quickSearchText)
                                .autocorrectionDisabled()
                                .autocapitalization(.none)
                                .onSubmit {
                                    if !quickSearchText.isEmpty && appState.reportedHorizontalSizeClass == .compact {
                                        generateQuickSearch()
                                    }
                                }
                            
                            if !quickSearchText.isEmpty && appState.reportedHorizontalSizeClass == .compact {
                                // Only show the button on compact screens (no auto-nav)
                                Button {
                                    generateQuickSearch()
                                } label: {
                                    Image(systemName: "magnifyingglass.circle")
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .onChange(of: quickSearchType) {
                            quickSearchText = ""
                            selectedSearch = nil
                        }
                        .onChange(of: quickSearchText) {
                            // Construct the search when the user taps the search button
                            selectedSearch = nil
                            
                            if quickSearchText.isEmpty || appState.reportedHorizontalSizeClass == .compact {
                                // Do not auto-navigate on small screens
                                return
                            }
                            
                            generateQuickSearch()
                        }
                    }
                    
                    Section("Details") {
                        HDeviceFormString(label: "Version", value: jamfProVersion)
                        
                        VStack(alignment: .leading) {
                            Text("Computers")
                            HDeviceFormInt(
                                label: "Managed",
                                value: jamfProInventoryInfo?.managedComputers,
                                copyable: false,
                                labelFont: .caption
                            )
                            HDeviceFormInt(
                                label: "Unmanaged",
                                value: jamfProInventoryInfo?.unmanagedComputers,
                                copyable: false,
                                labelFont: .caption
                            )
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Mobile Devices")
                            HDeviceFormInt(
                                label: "Managed",
                                value: jamfProInventoryInfo?.managedDevices,
                                copyable: false,
                                labelFont: .caption
                            )
                            HDeviceFormInt(
                                label: "Unmanaged",
                                value: jamfProInventoryInfo?.unmanagedDevices,
                                copyable: false,
                                labelFont: .caption
                            )
                        }
                        
                        Button {
                            Task {
                                do {
                                    let accessToken = try await server.client.AccessToken()
                                    UIPasteboard.general.string = accessToken
                                } catch {
                                    appState.logger.error("\(error.localizedDescription)")
                                }
                            }
                            showCopied.toggle()
                        } label: {
                            HStack {
                                Text("Get Access Token")
                                InlineIcon(name: "doc.on.doc")
                            }
                        }
                        .buttonStyle(.plain)
                        .popover(
                            isPresented: $showCopied,
                            attachmentAnchor: .point(.bottom),
                            arrowEdge: .top
                        ) {
                            Text("Token copied to clipboard!")
                                .padding()
                                .presentationCompactAdaptation(.popover)
                        }
                    }
                    
                    Section("Saved Searches") {
                        ForEach(server.searches.sorted(by: { $0.name < $1.name })) { search in
                            NavigationLink(value: search) {
                                HStack {
                                    switch search.searchType {
                                    case .computer:
                                        InlineIcon(name: "desktopcomputer.and.macbook")
                                    case .mobileDevice:
                                        InlineIcon(name: "ipad.landscape.and.iphone")
                                    }

                                    Text(search.name)
                                }
                                .tag(search)
                            }
                        }
                        .onDelete(perform: deleteSearch)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .task {
                if let apiTask, !apiTask.isCancelled {
                    appState.logger.warning("Existing server API task found...")
                    apiTask.cancel()
                    await apiTask.value
                }
                
                jamfProVersion = ""
                jamfProInventoryInfo = nil
                jamfProNotifications = []
                
                apiTask = Task {
                    let taskId = "\(server.hostname) \(UUID())"
                    
                    defer {
                        appState.logger.info("Setting server API task to 'nil': \(taskId)")
                        apiTask = nil
                    }
                    
                    appState.logger.info("Starting server API task: \(taskId)")
                    do {
                        try Task.checkCancellation()
                        jamfProVersion = try await server.client.api.JamfProVersionGetV1().ok.body.json.version ?? "Unknown"
                        jamfProInventoryInfo = try await server.client.api.InventoryInformationGetV1().ok.body.json
                        jamfProNotifications = try await server.client.api.JamfProNotificationsGetV1().ok.body.json
                        appState.logger.info("Server API task completed: \(taskId)")
                    } catch is CancellationError {
                        appState.logger.warning("Server API task cancelled: \(taskId)")
                    } catch {
                        appState.logger.error("Server API task error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func deleteSearch(at offsets: IndexSet) {
        for offset in offsets {
            let searchToDelete = server.searches[offset]
            withAnimation {
                modelContext.delete(searchToDelete)
                try? modelContext.save()
                selectedSearch = nil
            }
        }
    }
    
    func generateQuickSearch() {
        switch quickSearchType {
        case .computer:
            var filters: [Filter] = [
                .init(field: "general.name", op: .equal_to, value: "*\(quickSearchText)*", andOr: .or),
                .init(field: "hardware.model", op: .equal_to, value: "*\(quickSearchText)*", andOr: .or),
                .init(field: "hardware.serialNumber", op: .equal_to, value: "*\(quickSearchText)*", andOr: .or),
                .init(field: "userAndLocation.username", op: .equal_to, value: "*\(quickSearchText)*", andOr: .or)
            ]
            
            if Int(quickSearchText) != nil {
                filters.insert(.init(field: "id", op: .equal_to, value: quickSearchText, andOr: .or), at: 0)
            }
            
            selectedSearch = Search(
                name: "Quick Search: \(quickSearchText)",
                searchType: quickSearchType,
                sort: [SortOption(field: "id", direction: .asc)],
                filters: filters
            )
            
        case .mobileDevice:
            var filters: [Filter] = [
                .init(field: "displayName", op: .equal_to, value: "*\(quickSearchText)*", andOr: .or),
                .init(field: "model", op: .equal_to, value: "*\(quickSearchText)*", andOr: .or),
                .init(field: "serialNumber", op: .equal_to, value: "*\(quickSearchText)*", andOr: .or),
                .init(field: "username", op: .equal_to, value: "*\(quickSearchText)*", andOr: .or)
            ]
            
            if Int(quickSearchText) != nil {
                filters.insert(.init(field: "mobileDeviceId", op: .equal_to, value: quickSearchText, andOr: .or), at: 0)
            }
            
            selectedSearch = Search(
                name: "Quick Search: \(quickSearchText)",
                searchType: quickSearchType,
                sort: [SortOption(field: "deviceId", direction: .asc)],
                filters: filters
            )
        }
    }
    
    struct NotificationItem: View {
        let notification: Components.Schemas.NotificationV1
        
        @State private var showingPopover = false
        
        var body: some View {
            let params = notification.params?.value as? [String: String]
            
            HStack {
                Text(notification._type!.rawValue)
                    .font(.subheadline)
                if params != nil && params != [:] {
                    Image(systemName: "info.circle")
                        .onTapGesture {
                            showingPopover = true
                        }
                }
            }
            .foregroundStyle(.secondary)
            .popover(isPresented: $showingPopover) {
                VStack {
                    ForEach(params?.sorted{$0.key < $1.key} ?? [], id: \.key) { key, value in
                        if key != "id" {
                            VStack {
                                Text(key)
                                    .font(.caption)
                                Text(value)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .presentationCompactAdaptation(.popover)
            }
        }
    }
}

#if DEBUG
#Preview {
    ServerView(server: JamfProServer.preview, selectedSearch: .constant(Search.allComputers))
}
#endif
