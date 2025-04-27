//
//  ComputeSearchResutlView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 8/26/24.
//

import SwiftUI

struct MobileDeviceSearchResultsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Environment(AppState.self) var appState
    
    @State private var apiTask: Task<Void, Never>?
    
    let server: JamfProServer
    let search: Search
    
    @State private var mobileDeviceSearchResults: UnifiedMobileDeviceInventorySearchResults?
    @State private var showMobileDeviceSearchResults: Bool = false

    @State private var searchText: String = ""
    
    @State private var showMobileDeviceCommandsSheet = false
    @State private var showExportSheet = false
    
    var filteredMobileDeviceSearchResults: [UnifiedMobileDeviceResponse] {
        let results = mobileDeviceSearchResults?.results ?? []
        if searchText.isEmpty  {
            return results
        } else {
            return results.filter {
                $0.mobileDeviceId.localizedStandardContains(searchText) ||
                $0.deviceType.localizedStandardContains(searchText) ||
                $0.general?.udid?.localizedStandardContains(searchText) ?? false ||
                $0.general?.displayName?.localizedStandardContains(searchText) ?? false ||
                $0.hardware?.wifiMacAddress?.localizedStandardContains(searchText) ?? false ||
                $0.hardware?.model?.localizedStandardContains(searchText) ?? false ||
                $0.hardware?.modelIdentifier?.localizedStandardContains(searchText) ?? false ||
                $0.hardware?.serialNumber?.localizedStandardContains(searchText) ?? false ||
                $0.userAndLocation?.emailAddress?.localizedStandardContains(searchText) ?? false ||
                $0.userAndLocation?.realName?.localizedStandardContains(searchText) ?? false ||
                $0.userAndLocation?.username?.localizedStandardContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        ZStack {
            appState.themeColor
                .opacity(colorScheme == .light ? 0.25 : 0.5)
                .edgesIgnoringSafeArea(.all)
            
            Form {
                Section("Results (\(filteredMobileDeviceSearchResults.count))") {
                    if horizontalSizeClass == .compact {
                        ForEach(filteredMobileDeviceSearchResults, id: \.self) { device in
                            NavigationLink(destination: MobileDeviceDetailView(client: server.client, mobileDeviceId: device.mobileDeviceId)) {
                                MobileDeviceItemCompact(mobileDevice: device)
                            }
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(), GridItem()]) {
                                ForEach(filteredMobileDeviceSearchResults, id: \.self) { device in
                                    VStack {
                                        NavigationLink(destination: MobileDeviceDetailView(client: server.client, mobileDeviceId: device.mobileDeviceId)) {
                                            MobileDeviceItemWide(mobileDevice: device)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.vertical, 2)
                                        
                                        if filteredMobileDeviceSearchResults.count % 2 == 0 {
                                            if !filteredMobileDeviceSearchResults.suffix(2).contains(device) {
                                                Divider()
                                            }
                                        } else if device != filteredMobileDeviceSearchResults.last {
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .opacity(showMobileDeviceSearchResults && !filteredMobileDeviceSearchResults.isEmpty ? 1 : 0)
            .overlay {
                if mobileDeviceSearchResults == nil {
                    VStack {
                        Text("Loading...")
                            .foregroundStyle(.secondary)
                        ProgressView()
                    }
                } else if mobileDeviceSearchResults != nil, mobileDeviceSearchResults?.totalCount ?? -1 == 0 {
                    ContentUnavailableView {
                        Label("No devices returned", systemImage: "exclamationmark.magnifyingglass")
                    } description: {
                        Text("Try creating a new search with different filters")
                    }
                }
            }
            .sheet(isPresented: $showMobileDeviceCommandsSheet) {
                MobileDeviceCommands()
            }
            .sheet(isPresented: $showExportSheet) {
                MobileDevicesExport()
            }
        }
        .navigationTitle(search.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(ServerThemeGradient(baseColor: appState.themeColor), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            Menu("Options", systemImage: "ellipsis.circle") {
                Button("Send Command") {
                    showMobileDeviceCommandsSheet = true
                }
                .tint(colorScheme == .light ? .blue : .white)
                
                Menu("Export", systemImage: "square.and.arrow.up") {
                    ShareLink(
                        item: MobileDevicesExportCSV(mobileDevices: filteredMobileDeviceSearchResults),
                        preview: SharePreview("Mobile Devices CSV Export", image: Image(systemName: "tablecells"))
                    ) {
                        HStack {
                            Text("CSV")
                            Spacer()
                            Image(systemName: "tablecells")
                        }
                    }
                    .tint(colorScheme == .light ? .blue : .white)
                    
                    ShareLink(
                        item: MobileDevicesExportJSON(mobileDevices: filteredMobileDeviceSearchResults),
                        preview: SharePreview("Mobile Devices JSON Export", image: Image(systemName: "ellipsis.curlybraces"))
                    ) {
                        HStack {
                            Text("JSON")
                            Spacer()
                            Image(systemName: "ellipsis.curlybraces")
                        }
                    }
                    .tint(colorScheme == .light ? .blue : .white)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .searchable(text: $searchText, prompt: "Filter results")
        .overlay {
            if mobileDeviceSearchResults != nil, mobileDeviceSearchResults?.totalCount ?? 0 > 0, filteredMobileDeviceSearchResults.isEmpty, !searchText.isEmpty {
                ContentUnavailableView {
                    Label("No devices matching \"\(searchText)\"", systemImage: "candybarphone")
                } description: {
                    Text("Try a different filter term")
                }
            }
        }
        .onChange(of: mobileDeviceSearchResults) {
            withAnimation {
                showMobileDeviceSearchResults = true
            }
        }
        .task {
            if let apiTask, !apiTask.isCancelled {
                apiTask.cancel()
                await apiTask.value
            }
            
            apiTask = Task {
                let taskId = "\(server.hostname) \(search.name) \(UUID())"
                
                defer { apiTask = nil }
                
                do {
                    try await getMobileDeviceSearchResults()
                    appState.logger.info("Mobile Device Search API task completed: \(taskId)")
                } catch is CancellationError {
                    appState.logger.warning("Mobile Device Search API task cancelled: \(taskId)")
                } catch {
                    appState.logger.error("Mobile Device Search API task error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getMobileDeviceSearchResults() async throws {
        var currentPage = -1
        
        while mobileDeviceSearchResults?.results?.count ?? 0 < mobileDeviceSearchResults?.totalCount ?? 1 {
            currentPage += 1
            
            let nextPage = try await server.client.api.MobileDevicesDetailGetV2(
                .init(
                    query: .init(
                        section: appState.includeUserAndLocationInSearches ? [.GENERAL, .HARDWARE, .USER_AND_LOCATION] : [.GENERAL, .HARDWARE],
                        page: currentPage,
                        page_hyphen_size: appState.pageSize
                    )
                )
            )
            
            let nextPageResults = try nextPage.ok.body.json
            
            if mobileDeviceSearchResults == nil {
                mobileDeviceSearchResults = .init(totalCount: nextPageResults.totalCount, results: nextPageResults.results?.map { UnifiedMobileDeviceResponse(device: $0) } ?? [])
            } else if nextPageResults.results!.count == 0 {
                return
            } else {
                mobileDeviceSearchResults?.results?.append(contentsOf: nextPageResults.results?.map { UnifiedMobileDeviceResponse(device: $0) } ?? [])
            }
        }
    }

    struct MobileDeviceItemCompact: View {
        let mobileDevice: UnifiedMobileDeviceResponse
        
        var body: some View {
            HStack {
                VStack {
                    MobileDeviceIcon(model: mobileDevice.hardware?.model ?? "Unknown")
                        .font(.largeTitle)
                    Text("\(mobileDevice.mobileDeviceId)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(.trailing, 10)
                
                VStack(alignment: .leading) {
                    VDeviceAttr(label: "Name", value: mobileDevice.general?.displayName)
                    VDeviceAttr(label: "Model", value: mobileDevice.hardware?.model)
                }
            }
        }
    }

    struct MobileDeviceItemWide: View {
        let mobileDevice: UnifiedMobileDeviceResponse
        
        var body: some View {
            HStack {
                VStack {
                    MobileDeviceIcon(model: mobileDevice.hardware?.model ?? "Unknown")
                        .font(.largeTitle)
                    Text("\(mobileDevice.mobileDeviceId)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(10)
                
                VStack(alignment:.leading) {
                    VDeviceAttr(label: "Name", value: mobileDevice.general?.displayName)
                        .padding(.bottom, 2)
                    VDeviceAttr(label: "Model", value: mobileDevice.hardware?.model)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MobileDeviceSearchResultsView(
            server: JamfProServer.preview,
            search: .allMobileDevices
        )
    }
}
#endif
