//
//  JamfProServerListView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 8/14/24.
//

import SwiftData
import SwiftUI

struct ServerSelectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    
    @Environment(AppState.self) var appState
    
    @Binding var selectedServer: JamfProServer?
    
    @State private var showAddServerSheet = false
    
    @State private var showDeleteServerPrompt = false
    @State private var pendingDeletionServer: JamfProServer?
    
    @Query var servers: [JamfProServer]
    
    var body: some View {
        List(servers, selection: $selectedServer) { server in
            NavigationLink(value: server) {
                ServerListViewItem(server: server)
                    .tag(server)
                    .swipeActions {
                        Button("Delete", systemImage: "trash") {
                            appState.logger.info("DELETE PROMPT FOR \(server.hostname)")
                            pendingDeletionServer = server
                            showDeleteServerPrompt = true
                        }
                        .tint(.red)
                    }
                    // TODO: This is still buggy - confirmation will not always point to the correct item visually
                    .confirmationDialog(
                        "Delete '\(pendingDeletionServer?.hostname ?? "")'?",
                        isPresented: $showDeleteServerPrompt,
                        titleVisibility: .visible
                    ) {
                        Button("Delete", role: .destructive) {
                            if let serverToDelete = pendingDeletionServer {
                                appState.logger.info("DELETING \(serverToDelete.hostname)")
                                withAnimation {
                                    modelContext.delete(serverToDelete)
                                    pendingDeletionServer = nil
                                    selectedServer = nil
                                }
                            }
                        }
                    }
                }
            }
        }
    
    struct ServerListViewItem: View {
        let server: JamfProServer
        
        var body: some View {
            HStack {
//                if server.isFavorite {
//                    Image(systemName: "star.fill")
//                        .foregroundStyle(.yellow)
//                }
                
                RoundedRectangle(cornerRadius: 5)
                    .fill(ServerThemeGradient(baseColor: Color(red: server.themeColorRGB.red, green: server.themeColorRGB.green, blue: server.themeColorRGB.blue)))
                    .stroke(.white, lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text(server.hostname)
                        .lineLimit(1)
                        .font(.headline)
                }
                .padding()
            }
        }
    }
}

#if DEBUG
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: JamfProServer.self, configurations: config)
    container.mainContext.insert(JamfProServer.preview)
        
    return ServerSelectionView(selectedServer: .constant(nil))
        .modelContainer(container)
}
#endif
