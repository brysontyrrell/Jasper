//
//  SettingsAdvancedView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 10/24/24.
//

import SwiftUI

struct SettingsAdvancedView: View {
    @AppStorage("pageSize") var pageSize: Int = 100
    @AppStorage("includeUserAndLocationInSearches") var includeUserAndLocationInSearches: Bool = true
    
    private let allowedPageSizes = [1, 10, 25, 50, 100, 250, 500, 1000, 2000]
    
    var body: some View {
        Form {
            Section {
                    Picker("API Page Size", selection: $pageSize) {
                        ForEach(allowedPageSizes, id: \.self) {
                            Text("\($0)")
                        }
                    }
            } header: {
                Text("API Settings")
            } footer: {
                Text("Adjust to troubleshoot searches and tune performance with large inventories.")
            }
            
            Section {
                Toggle(isOn: $includeUserAndLocationInSearches) {
                    Text("User and Location Data")
                }
            } footer: {
                Text("Disabling may speed up API responses but limit filtering options on search results.")
            }
        }
        .navigationTitle("Advanced Options")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsAdvancedView()
}
