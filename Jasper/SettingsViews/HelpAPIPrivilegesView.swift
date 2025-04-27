//
//  HelpPermissionsView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 10/13/24.
//

import SwiftUI

struct HelpAPIPrivilegesView: View {

    var body: some View {
        Form {
            Text("""
            API privileges required by Jasper.
            
            For instructions on how to create and configure API Roles and Clients visit the [Jamf Pro Documentation](https://learn.jamf.com/en-US/bundle/jamf-pro-documentation-current/page/API_Roles_and_Clients.html).
            
            To learn more about about Jamf Pro API privileges visit the [Jamf Pro Developer Portal](https://developer.jamf.com/jamf-pro/docs/privileges-and-deprecations).
            """)
            
            Section("Server Details") {
                Text("No additional privileges required.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            }
            
            Section("Device Inventory") {
                PrivilegeText(privilege: "Read Computers", description: "View computer inventory.")
                PrivilegeText(privilege: "Read Mobile Devices", description: "View mobile device inventory.")
            }
            
            Section("Computer Commands") {
                // DEVICE_LOCK
                PrivilegeText(privilege: "Send Computer Remote Lock Command", description: "Lock a computer.")
                // ERASE_DEVICE
                PrivilegeText(privilege: "Send Computer Remote Wipe Command", description: "Erase a computer.")
            }
            
            Section("Mobile Device Commands") {
                // DEVICE_LOCK
                PrivilegeText(privilege: "Send Mobile Device Remote Lock Command", description: "Lock a mobile device.")
                // ENABLE_LOST_MODE
                PrivilegeText(privilege: "Send Mobile Device Lost Mode Command", description: "Put a mobile device into lost mode.")
                // RESTART_DEVICE
                PrivilegeText(privilege: "Send Mobile Device Restart Command", description: "Power off a mobile device.")
                // SHUT_DOWN_DEVICE
                PrivilegeText(privilege: "Send Mobile Device Shut Down Command", description: "Power off a mobile device.")
                // ERASE_DEVICE
                PrivilegeText(privilege: "Send Mobile Device Remote Wipe Command", description: "Erase a mobile device.")
            }
        }
        .navigationTitle("API Client Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivilegeText: View {
    let privilege: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(privilege)
                .lineLimit(1)
            Text(description)
                .font(.caption)
        }
    }
}

#Preview {
    NavigationStack {
        HelpAPIPrivilegesView()
    }
}
