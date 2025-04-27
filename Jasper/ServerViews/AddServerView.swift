//
//  AddServerView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 8/8/24.
//

import SwiftData
import SwiftUI

struct AddServerView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Environment(AppState.self) var appState
    
    @Binding var selectedServer: JamfProServer?
    
    @State private var hostname = ""
    @State private var port = 443
    
    @State private var clientId = ""
    @State private var clientSecret = ""
    
    @State private var themeColor = Color("JamfBlue1")
    
    @State private var showClientTestError = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Server") {
                    HStack {
                        Text("Hostname")
                            .font(.headline)
                        Spacer()
                        TextField("my.jamf.pro", text: $hostname)
                            .keyboardType(.webSearch)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Port")
                            .font(.headline)
                        Spacer()
                        TextField("Port", value: $port, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                    
                Section("Credentials") {
                    
                    HStack {
                        Text("Client ID")
                            .font(.headline)
                        Image(systemName: "questionmark.circle")
                            .overlay {
                                NavigationLink(destination: HelpAPIPrivilegesView()) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                        Spacer()
                        TextField("abc123", text: $clientId)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Client Secret")
                            .font(.headline)
                        Spacer()
                        SecureField("******", text: $clientSecret)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                            .multilineTextAlignment(.trailing)
                    }
                }
                    
                Section("Theme") {
                    HStack {
                        Text("Color")
                            .font(.headline)
                        Spacer()
                        ServerThemeGradient(baseColor: themeColor)
                            .cornerRadius(5)
                            .listRowSeparator(.hidden)
                            .padding()
                        Spacer()
                        ColorPicker("Theme Color", selection: $themeColor, supportsOpacity: false)
                            .labelsHidden()
                    }
                }
            }
            .navigationTitle("Add Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            do {
                                let testClient = AccessTokenManager(
                                    tokenURL: URL(string: "https://\(hostname):\(port)/api/oauth/token")!,
                                    clientId: clientId,
                                    clientSecret: clientSecret
                                )
                                let testToken = try await testClient.requestAccessToken()
                                
                                appState.logger.info("NEW SERVER '\(hostname)' SUCCESSFUL TOKEN REQUEST: \(testToken.expiration_date)")
                                
                                let newServer = JamfProServer(
                                    hostname: hostname,
                                    port: port,
                                    clientId: clientId,
                                    clientSecret: clientSecret,
                                    themeColor: themeColor,
                                    isFavorite: false
                                )
                                modelContext.insert(newServer)
                                selectedServer = newServer
                                dismiss()
                            } catch {
                                appState.logger.error("\(error.localizedDescription)")
                                showClientTestError = true
                            }
                        }
                    }
                    .disabled(hostname.isEmpty || !(0...65535).contains(port) || clientId.isEmpty || clientSecret.isEmpty)
                }
            }
            .alert(isPresented: $showClientTestError) {
                Alert(title: Text("Unable to authenticate"), message: Text("Verify your server details and try again."))
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddServerView(selectedServer: .constant(nil))
    }
}
