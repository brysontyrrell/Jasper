//
//  ComputerView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 9/19/24.
//

import SwiftUI

struct ComputerDetailsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @Environment(AppState.self) var appState
    
    @State private var apiTask: Task<Void, Never>?
    
    let client: JamfProAPIClient
    let computerId: String
    
    @State private var computer: Components.Schemas.ComputerInventory?
    
    @State private var showingGeneralSection = true
    @State private var showingHardwareSection = true
    @State private var showingOperatingSystemSection = true
    @State private var showingUserAndLocationSection = true
    @State private var showingSecuritySection = true
    @State private var showingDiskEncryptionSection = true
    @State private var showingApplicationsSection = true
    @State private var showingConfigProfilesSection = true
    @State private var showingCertificatesSection = true
    @State private var showingGroupMembershipsSection = true
    
    private var sectionsAreExpanded: Bool {
        showingGeneralSection || showingHardwareSection || showingOperatingSystemSection || showingUserAndLocationSection || showingSecuritySection || showingDiskEncryptionSection || showingApplicationsSection || showingConfigProfilesSection || showingCertificatesSection || showingGroupMembershipsSection
    }
    
    var body: some View {
        ZStack {
            appState.themeColor
                .opacity(colorScheme == .light ? 0.25 : 0.5)
                .edgesIgnoringSafeArea(.all)
            
            Form {
                HDeviceFormString(label: "Name", value: computer?.general?.name)
                HDeviceFormString(label: "ID", value: computerId)
                HDeviceFormString(label: "Management ID", value: computer?.general?.managementId)
                HDeviceFormString(label: "Model", value: computer?.hardware?.model)
                HDeviceFormString(label: "Serial Number", value: computer?.hardware?.serialNumber)
                HDeviceFormString(label: "User", value: computer?.userAndLocation?.username)
                
                // GENERAL
                Section(isExpanded: $showingGeneralSection) {
                    HDeviceFormString(label: "Site Name", value: computer?.general?.site?.name)
                    
                    HDeviceFormString(label: "Jamf Binary", value: computer?.general?.jamfBinaryVersion)
                    
                    HDeviceFormDate(label: "Last Contact", value: computer?.general?.lastContactTime)
                    HDeviceFormDate(label: "Last Enrolled", value: computer?.general?.lastEnrolledDate)
                    HDeviceFormDate(label: "MDM Expires", value: computer?.general?.mdmProfileExpiration)
                    
                    HDeviceFormBool(label: "Managed?", value: computer?.general?.remoteManagement?.managed)
                    HDeviceFormBool(label: "Supervised?", value: computer?.general?.supervised)
                    HDeviceFormBool(label: "User Enrolled?", value: computer?.general?.userApprovedMdm)
                    
                    
                    HDeviceFormString(label: "Last IP", value: computer?.general?.lastIpAddress)
                } header: {
                    DeviceViewSectionHeader(title: "General", sectionToggle: $showingGeneralSection)
                }
                
                // HARDWARE
                Section(isExpanded: $showingHardwareSection) {
                    HDeviceFormString(label: "Model", value: computer?.hardware?.model)
                    HDeviceFormString(label: "Model ID", value: computer?.hardware?.modelIdentifier)
                    HDeviceFormString(label: "UDID", value: computer?.udid)
                    HDeviceFormString(label: "Processor", value: computer?.hardware?.processorType)
                    HDeviceFormString(label: "Architecture", value: computer?.hardware?.processorArchitecture)
                    HDeviceFormBytes(label: "Memory", value: (computer?.hardware?.totalRamMegabytes ?? 0) * 1024 * 1024)
                    HDeviceFormString(label: "MAC Address", value: computer?.hardware?.macAddress)
                    HDeviceFormString(label: "Alt MAC Address", value: computer?.hardware?.altMacAddress)
                } header: {
                    DeviceViewSectionHeader(title: "Hardware", sectionToggle: $showingHardwareSection)
                }
                
                // OPERATING SYSTEM
                Section(isExpanded: $showingOperatingSystemSection) {
                    HDeviceFormString(label: "Version", value: computer?.operatingSystem?.version)
                    HDeviceFormString(label: "Build", value: computer?.operatingSystem?.build)
                    HDeviceFormString(label: "RSR", value: computer?.operatingSystem?.rapidSecurityResponse)
                } header: {
                    DeviceViewSectionHeader(title: "Operating System", sectionToggle: $showingOperatingSystemSection)
                }
                
                // USER AND LOCATION
                Section(isExpanded: $showingUserAndLocationSection) {
                    HDeviceFormString(label: "Real Name", value: computer?.userAndLocation?.realname)
                    HDeviceFormString(label: "Email", value: computer?.userAndLocation?.email)
                    HDeviceFormString(label: "Position", value: computer?.userAndLocation?.position)
                } header: {
                    DeviceViewSectionHeader(title: "User and Location", sectionToggle: $showingUserAndLocationSection)
                }
                
                // SECURITY
                Section(isExpanded: $showingSecuritySection) {
                    HDeviceFormString(label: "XProtect Version", value: computer?.security?.xprotectVersion)
                    HDeviceFormString(label: "SIP Enabled?", value: computer?.security?.sipStatus?.rawValue)
                    HDeviceFormString(label: "Gatekeeper Status", value: computer?.security?.gatekeeperStatus?.rawValue)
                    HDeviceFormBool(label: "Activation Lock?", value: computer?.security?.activationLockEnabled)
                    HDeviceFormBool(label: "Recovery Lock?", value: computer?.security?.recoveryLockEnabled)
                    HDeviceFormBool(label: "Firewall Enabled?", value: computer?.security?.firewallEnabled)
                } header: {
                    DeviceViewSectionHeader(title: "Security", sectionToggle: $showingSecuritySection)
                }
                
                // DISK ENCRYPTION
                Section(isExpanded: $showingDiskEncryptionSection) {
                    HDeviceFormString(label: "Boot FV2 State", value: computer?.diskEncryption?.bootPartitionEncryptionDetails?.partitionFileVault2State?.rawValue)
                    HDeviceFormInt(label: "Boot FV2 %", value: computer?.diskEncryption?.bootPartitionEncryptionDetails?.partitionFileVault2Percent)
                    HDeviceFormString(label: "Recovery Key Status", value: computer?.diskEncryption?.individualRecoveryKeyValidityStatus?.rawValue)
                    HDeviceFormBool(label: "Recovery Key Present?", value: computer?.diskEncryption?.institutionalRecoveryKeyPresent)
                    
                    VStack {
                        Text("FileVault Enabled Users")
                        ForEach(computer?.diskEncryption?.fileVault2EnabledUserNames ?? [], id: \.self) { user in
                            Text(user)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    DeviceViewSectionHeader(title: "Disk Encryption", sectionToggle: $showingDiskEncryptionSection)
                }
                
                // APPLICATIONS
                Section(isExpanded: $showingApplicationsSection) {
                    ForEach(computer?.applications ?? [], id: \.self) { application in
                        VStack {
                            HStack {
                                HDeviceFormString(label: "Name", value: application.name)
                                if application.macAppStore ?? false {
                                    AppStoreInlineIcon()
                                }
                            }
                            HDeviceFormString(label: "Bundle ID", value: application.bundleId, copyable: false, labelFont: .caption)
                            HDeviceFormString(label: "Version", value: application.version, copyable: false, labelFont: .caption)
                        }
                    }
                } header: {
                    DeviceViewSectionHeader(title: "Applications", sectionToggle: $showingApplicationsSection)
                }
                
                // CONFIG PROFILES
                Section(isExpanded: $showingConfigProfilesSection) {
                    ForEach(computer?.configurationProfiles ?? [], id: \.self) { profile in
                        VStack {
                            HDeviceFormString(label: "Name", value: profile.displayName)
                            HDeviceFormString(label: "Identifier", value: profile.profileIdentifier, copyable: false, labelFont: .caption)
                            HDeviceFormDate(label: "Last Installed", value: profile.lastInstalled, labelFont: .caption)
                        }
                    }
                } header: {
                    DeviceViewSectionHeader(title: "Config Profiles", sectionToggle: $showingConfigProfilesSection)
                }
                
                // CERTIFICATES
                Section(isExpanded: $showingCertificatesSection) {
                    ForEach(computer?.certificates ?? [], id: \.self) { certificate in
                        VStack {
                            HDeviceFormString(label: "Common Name", value: certificate.commonName)
                            HDeviceFormString(label: "Fingerprint", value: certificate.sha1Fingerprint, copyable: false, labelFont: .caption)
                            HDeviceFormDate(label: "Expires", value: certificate.expirationDate, labelFont: .caption)
                        }
                    }
                } header: {
                    DeviceViewSectionHeader(title: "Certificates", sectionToggle: $showingCertificatesSection)
                }
                
                // GROUP MEMBERSHIPS
                Section(isExpanded: $showingGroupMembershipsSection) {
                    ForEach(computer?.groupMemberships ?? [], id: \.groupId) { group in
                        VStack {
                            HDeviceFormString(label: "Name", value: group.groupName)
                            HDeviceFormString(label: "ID", value: group.groupId, copyable: false, labelFont: .caption)
                            HDeviceFormBool(label: "Is Smart?", value: group.smartGroup, labelFont: .caption)
                        }
                    }
                } header: {
                    DeviceViewSectionHeader(title: "Group Memberships", sectionToggle: $showingGroupMembershipsSection)
                }
            }
        }
        .navigationTitle(computer?.general?.name ?? computer?.hardware?.serialNumber ?? "Computer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(ServerThemeGradient(baseColor: appState.themeColor), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            Menu("Options", systemImage: "ellipsis.circle") {
                Button(sectionsAreExpanded == true ? "Collapse All" : "Expand All") {
                    let newSectionState = sectionsAreExpanded == true ? false : true
                    withAnimation {
                        showingGeneralSection = newSectionState
                        showingHardwareSection = newSectionState
                        showingOperatingSystemSection = newSectionState
                        showingUserAndLocationSection = newSectionState
                        showingSecuritySection = newSectionState
                        showingDiskEncryptionSection = newSectionState
                        showingApplicationsSection = newSectionState
                        showingConfigProfilesSection = newSectionState
                        showingCertificatesSection = newSectionState
                        showingGroupMembershipsSection = newSectionState
                    }
                }
                Button("Send Command") {}
                    .tint(colorScheme == .light ? .blue : .white)
                
                Button {
                    if computer != nil {
                        let computerData = try! JSONEncoder().encode(computer)
                        UIPasteboard.general.string = String(data: computerData, encoding: .utf8)
                    }
                } label: {
                    HStack {
                        Text("Copy JSON")
                        Image(systemName: "ellipsis.curlybraces")
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .task {
            if let apiTask, !apiTask.isCancelled {
                apiTask.cancel()
                await apiTask.value
            }
            
            apiTask = Task {
                let taskId = "\(client.clientId) Computer \(computerId) \(UUID())"
                
                defer { apiTask = nil }
                
                do {
                    let response = try await client.api.ComputersInventoryDetailByIdGetV1(path: .init(id: computerId))
                    computer = try response.ok.body.json
                    appState.logger.info("Computer Inventory API task completed: \(taskId)")
                } catch is CancellationError {
                    appState.logger.warning("Computer Inventory API task cancelled: \(taskId)")
                } catch {
                    appState.logger.error("Computer Inventory API task error: \(error.localizedDescription)")
                }
            }
        }
    }
}

//#Preview {
//    ComputerDetailsView()
//}
