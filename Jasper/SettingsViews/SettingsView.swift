//
//  SettingsSheet.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 9/28/24.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    let appVersion = Bundle.main.releaseVersionNumber ?? "?"
    let appBuild = Bundle.main.buildVersionNumber ?? "?"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Help") {
                    NavigationLink(destination: HelpAPIPrivilegesView()) {
                        Text("API Client")
                    }
                    
                    NavigationLink(destination: HelpQuickSearchView()) {
                        Text("Quick Search")
                    }
                    
                    Text("Saved Searches")
                        .foregroundStyle(.secondary)
                }
                
                Section("App Settings") {
                    HStack {
                        Toggle(isOn: .constant(false)) {
                            Text("Require Authentication")
                        }
                    }
                    
                    HStack {
                        Toggle(isOn: .constant(false)) {
                            Text("Enable Notifications")
                        }
                    }
                    
                    NavigationLink(destination: SettingsAdvancedView()) {
                        Text("Advanced Options")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("\(appVersion) (\(appBuild))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
