//
//  ComputeSearchResutlView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 8/26/24.
//

import SwiftUI

struct ComputerSearchResultsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Environment(AppState.self) var appState
    
    @State private var apiTask: Task<Void, Never>?
    
    let server: JamfProServer
    let search: Search
    
    @State private var computerSearchResults: Components.Schemas.ComputerInventorySearchResults?
    @State private var showComputerSearchResults: Bool = false

    @State private var searchText: String = ""
    
    @State private var showComputerCommandsSheet = false
    
    var filteredComputerSearchResults: [Components.Schemas.ComputerInventory] {
        let results = computerSearchResults?.results ?? []
        if searchText.isEmpty  {
            return results
        } else {
            return results.filter {
                $0.id?.localizedStandardContains(searchText) ?? false ||
                $0.udid?.localizedStandardContains(searchText) ?? false ||
                $0.general?.name?.localizedStandardContains(searchText) ?? false ||
                $0.general?.managementId?.localizedStandardContains(searchText) ?? false ||
                $0.hardware?.macAddress?.localizedStandardContains(searchText) ?? false ||
                $0.hardware?.model?.localizedStandardContains(searchText) ?? false ||
                $0.hardware?.modelIdentifier?.localizedStandardContains(searchText) ?? false ||
                $0.hardware?.serialNumber?.localizedStandardContains(searchText) ?? false ||
                $0.userAndLocation?.email?.localizedStandardContains(searchText) ?? false ||
                $0.userAndLocation?.realname?.localizedStandardContains(searchText) ?? false ||
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
                Section("Results (\(filteredComputerSearchResults.count))") {
                    if horizontalSizeClass == .compact {
                        ForEach(filteredComputerSearchResults, id: \.id) { computer in
                            NavigationLink(destination: ComputerDetailsView(client: server.client, computerId: computer.id!)) {
                                ComputerItemCompact(computer: computer)
                            }
                        }
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(), GridItem()]) {
                                ForEach(filteredComputerSearchResults, id: \.id) { computer in
                                    VStack {
                                        NavigationLink(destination: ComputerDetailsView(client: server.client, computerId: computer.id!)) {
                                            ComputerItemWide(computer: computer)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.vertical, 2)
                                        
                                        if filteredComputerSearchResults.count % 2 == 0 {
                                            if !filteredComputerSearchResults.suffix(2).contains(computer) {
                                                Divider()
                                            }
                                        } else if computer != filteredComputerSearchResults.last {
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .opacity(showComputerSearchResults && !filteredComputerSearchResults.isEmpty ? 1 : 0)
            .overlay {
                if computerSearchResults == nil {
                    VStack {
                        Text("Loading...")
                            .foregroundStyle(.secondary)
                        ProgressView()
                    }
                } else if computerSearchResults != nil, computerSearchResults?.totalCount ?? -1 == 0 {
                    ContentUnavailableView {
                        Label("No computers returned", systemImage: "exclamationmark.magnifyingglass")
                    } description: {
                        Text("Try creating a new search with different filters")
                    }
                }
            }
            .sheet(isPresented: $showComputerCommandsSheet) {
                ComputerCommands()
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
                    showComputerCommandsSheet = true
                }

                Menu("Export", systemImage: "square.and.arrow.up") {
                    ShareLink(
                        item: ComputersExportCSV(computers: filteredComputerSearchResults),
                        preview: SharePreview("Computers CSV Export", image: Image(systemName: "tablecells"))
                    ) {
                        HStack {
                            Text("CSV")
                            Spacer()
                            Image(systemName: "tablecells")
                        }
                    }
                    .tint(colorScheme == .light ? .blue : .white)
                    
                    ShareLink(
                        item: ComputersExportJSON(computers: filteredComputerSearchResults),
                        preview: SharePreview("Computers JSON Export", image: Image(systemName: "ellipsis.curlybraces"))
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
            if computerSearchResults != nil, computerSearchResults?.totalCount ?? 0 > 0, filteredComputerSearchResults.isEmpty, !searchText.isEmpty {
                ContentUnavailableView {
                    Label("No computers matching \"\(searchText)\"", systemImage: "pc")
                } description: {
                    Text("Try a different filter term")
                }
            }
        }
        .onChange(of: computerSearchResults) {
            withAnimation {
                showComputerSearchResults = true
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
                    try await getComputerSearchResults()
                    appState.logger.info("Computer Search API task completed: \(taskId)")
                } catch is CancellationError {
                    appState.logger.warning("Computer Search API task cancelled: \(taskId)")
                } catch {
                    appState.logger.error("Computer Search API task error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getComputerSearchResults() async throws {
        var currentPage = -1
        
        while computerSearchResults?.results?.count ?? 0 < computerSearchResults?.totalCount ?? 1 {
            currentPage += 1
            
            let nextPage = try await server.client.api.ComputersInventoryGetV1(
                .init(
                    query: .init(
                        section: appState.includeUserAndLocationInSearches ? [.GENERAL, .HARDWARE, .USER_AND_LOCATION] : [.GENERAL, .HARDWARE],
                        page: currentPage,
                        page_hyphen_size: appState.pageSize
                    )
                )
            )
            
            let nextPageResults = try nextPage.ok.body.json
            
            if computerSearchResults == nil {
                computerSearchResults = .init(totalCount: nextPageResults.totalCount, results: nextPageResults.results)
            } else if nextPageResults.results!.count == 0 {
                return
            } else {
                computerSearchResults?.results?.append(contentsOf: nextPageResults.results ?? [])
            }
        }
    }
    
    struct ComputerItemCompact: View {
        let computer: Components.Schemas.ComputerInventory
        
        var body: some View {
            HStack {
                VStack {
                    ComputerIcon(model: computer.hardware?.model ?? "Unknown")
                        .font(.largeTitle)
                    Text("\(computer.id!)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(.trailing, 10)
                
                VStack(alignment: .leading) {
                    VDeviceAttr(label: "Name", value: computer.general?.name)
                    VDeviceAttr(label: "Model", value: computer.hardware?.model)
                }
            }
        }
    }
    
    struct ComputerItemWide: View {
        let computer: Components.Schemas.ComputerInventory
        
        var body: some View {
            HStack {
                VStack {
                    ComputerIcon(model: computer.hardware?.model ?? "Unknown")
                        .font(.largeTitle)
                    Text("\(computer.id!)")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .padding(10)
                
                VStack(alignment:.leading) {
                    VDeviceAttr(label: "Name", value: computer.general?.name)
                        .padding(.bottom, 2)
                    VDeviceAttr(label: "Model", value: computer.hardware?.model)
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
        ComputerSearchResultsView(
            server: .preview,
            search: .allComputers
        )
    }
}
#endif
