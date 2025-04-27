//
//  MobileDeviceView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 9/19/24.
//

import SwiftUI

struct MobileDeviceDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(AppState.self) var appState
    
    @State private var apiTask: Task<Void, Never>?
    
    let client: JamfProAPIClient
    let mobileDeviceId: String
    
    @State private var mobileDevice: Components.Schemas.MobileDeviceDetailsGetV2?
    
    // Conditional sections populated if device type matches
    @State private var mdModel: String?
    @State private var mdModelIdentifier: String?
    @State private var mdModelNumber: String?
    
    @State private var mdSecurity: Components.Schemas.SecurityV2?
    @State private var mdNetwork: Components.Schemas.NetworkV2?
    @State private var mdApplications: [Components.Schemas.MobileDeviceApplication]?
    @State private var mdConfigProfiles: [Components.Schemas.ConfigurationProfile]?
    @State private var mdProvisioningProfiles: [Components.Schemas.MobileDeviceProvisioningProfiles]?
    @State private var mdCertificates: [Components.Schemas.MobileDeviceCertificateV2]?
    
    @State private var showingGeneralSection = true
    @State private var showingHardwareSection = true
    @State private var showingOperatingSystemSection = true
    @State private var showingUserAndLocationSection = true
    @State private var showingSecuritySection = true // iOS, watchOS, visionOS
    @State private var showingNetworkSection = true // iOS, ~visionOS~ (excluded)
    @State private var showingApplicationsSection = true // iOS, watchOS, visionOS
    @State private var showingConfigProfilesSection = true // iOS, tvOS, watchOS, visionOS
    @State private var showingProvisioningProfilesSection = true // iOS, watchOS, visionOS
    @State private var showingCertificatesSection = true // iOS, tvOS, watchOS, visionOS
    
    private var sectionsAreExpanded: Bool {
        showingGeneralSection || showingHardwareSection || showingOperatingSystemSection || showingUserAndLocationSection || showingSecuritySection || showingNetworkSection || showingApplicationsSection || showingConfigProfilesSection || showingProvisioningProfilesSection || showingCertificatesSection
    }
    
    var body: some View {
        ZStack {
            appState.themeColor
                .opacity(colorScheme == .light ? 0.25 : 0.5)
                .edgesIgnoringSafeArea(.all)
            
            Form {
                HDeviceFormString(label: "Name", value: mobileDevice?.value1.name)
                HDeviceFormString(label: "ID", value: mobileDeviceId)
                HDeviceFormString(label: "Management ID", value: mobileDevice?.value2.managementId)
                HDeviceFormString(label: "Model", value: mdModel)
                HDeviceFormString(label: "Serial Number", value: mobileDevice?.value1.serialNumber)
                HDeviceFormString(label: "User", value: mobileDevice?.value1.location?.username)
                
                // GENERAL
                Section(isExpanded: $showingGeneralSection) {
                    HDeviceFormString(label: "Site Name", value: mobileDevice?.value1.site?.name)
                    
                    HDeviceFormDate(label: "Last Contact", value: mobileDevice?.value1.lastInventoryUpdateTimestamp)
                    HDeviceFormDate(label: "Last Enrolled", value: mobileDevice?.value1.lastEnrollmentTimestamp)
                    HDeviceFormDate(label: "MDM Expires", value: mobileDevice?.value1.mdmProfileExpirationTimestamp)
                    
                    HDeviceFormBool(label: "Managed?", value: mobileDevice?.value1.managed)
                    // HDeviceFormBool(label: "Supervised?", value: computer?.general?.supervised) DEVICE SPECIFIC
                    HDeviceFormString(label: "Enrollment", value: mobileDevice?.value1.enrollmentMethod)
                    
                    
                    HDeviceFormString(label: "Last IP", value: mobileDevice?.value1.ipAddress)
                } header: {
                    DeviceViewSectionHeader(title: "General", sectionToggle: $showingGeneralSection)
                }
                
                // HARDWARE (device specific)
                Section(isExpanded: $showingHardwareSection) {
                    HDeviceFormString(label: "Model ID", value: mdModelIdentifier)
                    HDeviceFormString(label: "Model Number", value: mdModelNumber)
                    HDeviceFormString(label: "UDID", value: mobileDevice?.value1.udid)
                    HDeviceFormString(label: "Wi-Fi MAC", value: mobileDevice?.value1.wifiMacAddress)
                    HDeviceFormString(label: "BlueTooth MAC", value: mobileDevice?.value1.bluetoothMacAddress)
                } header: {
                    DeviceViewSectionHeader(title: "Hardware", sectionToggle: $showingHardwareSection)
                }
                
                // OPERATING SYSTEM (GENERAL)
                Section(isExpanded: $showingOperatingSystemSection) {
                    HDeviceFormString(label: "Version", value: mobileDevice?.value1.osVersion)
                    HDeviceFormString(label: "Build", value: mobileDevice?.value1.osBuild)
                    HDeviceFormString(label: "Supplemental", value: mobileDevice?.value1.osSupplementalBuildVersion)
                    HDeviceFormString(label: "RSR", value: mobileDevice?.value1.osRapidSecurityResponse)
                } header: {
                    DeviceViewSectionHeader(title: "Operating System", sectionToggle: $showingOperatingSystemSection)
                }
                
                // (USER AND) LOCATION
                Section(isExpanded: $showingUserAndLocationSection) {
                    HDeviceFormString(label: "Real Name", value: mobileDevice?.value1.location?.realName)
                    HDeviceFormString(label: "Email", value: mobileDevice?.value1.location?.emailAddress)
                    HDeviceFormString(label: "Position", value: mobileDevice?.value1.location?.position)
                } header: {
                    DeviceViewSectionHeader(title: "User and Location", sectionToggle: $showingUserAndLocationSection)
                }
                
                if mdSecurity != nil {
                    Section(isExpanded: $showingSecuritySection) {
                        HDeviceFormBool(label: "Passcode?", value: mdSecurity?.passcodePresent)
                        HDeviceFormBool(label: "Compliant?", value: mdSecurity?.passcodeCompliant)
                        HDeviceFormBool(label: "Activation Lock Enabled?", value: mdSecurity?.activationLockEnabled)
                        HDeviceFormBool(label: "Jailbroken?", value: mdSecurity?.jailBreakDetected)
                    } header: {
                        DeviceViewSectionHeader(title: "Security", sectionToggle: $showingSecuritySection)
                    }
                }
                
                if mdNetwork != nil {
                    Section(isExpanded: $showingNetworkSection) {
                        HDeviceFormString(label: "Carrier", value: mdNetwork?.currentCarrierNetwork)
                        HDeviceFormString(label: "IMEI", value: mdNetwork?.imei)
                        HDeviceFormString(label: "ICCID", value: mdNetwork?.iccid)
                        HDeviceFormString(label: "MEID", value: mdNetwork?.meid)
                        HDeviceFormString(label: "EID", value: mdNetwork?.eid)
                    } header: {
                        DeviceViewSectionHeader(title: "Network", sectionToggle: $showingNetworkSection)
                    }
                }
                
                if mdApplications != nil {
                    Section(isExpanded: $showingApplicationsSection) {
                        ForEach(mdApplications ?? [], id: \.self) { application in
                            VStack {
                                HDeviceFormString(label: "Name", value: application.name)
                                HDeviceFormString(label: "Bundle ID", value: application.identifier, copyable: false, labelFont: .caption)
                                HDeviceFormString(label: "Version", value: application.version, copyable: false, labelFont: .caption)
                                HDeviceFormString(label: "Short Version", value: application.shortVersion, copyable: false, labelFont: .caption)
                            }
                        }
                    } header: {
                        DeviceViewSectionHeader(title: "Applications", sectionToggle: $showingApplicationsSection)
                    }
                }
                
                if mdConfigProfiles != nil {
                    Section(isExpanded: $showingConfigProfilesSection) {
                        ForEach(mdConfigProfiles ?? [], id: \.self) { profile in
                            VStack {
                                HDeviceFormString(label: "Name", value: profile.displayName)
                                HDeviceFormString(label: "Identifier", value: profile.identifier, copyable: false, labelFont: .caption)
                                HDeviceFormString(label: "UUID", value: profile.uuid, copyable: false, labelFont: .caption)
                            }
                        }
                    } header: {
                        DeviceViewSectionHeader(title: "Config Profiles", sectionToggle: $showingConfigProfilesSection)
                    }
                }
                
                if mdProvisioningProfiles != nil {
                    Section(isExpanded: $showingProvisioningProfilesSection) {
                        ForEach(mdProvisioningProfiles ?? [], id: \.self) { profile in
                            VStack {
                                HDeviceFormString(label: "Name", value: profile.displayName)
                                HDeviceFormString(label: "UUID", value: profile.uuid, copyable: false, labelFont: .caption)
                                HDeviceFormDate(label: "Expires", value: profile.expirationDate, labelFont: .caption)
                            }
                        }
                    } header: {
                        DeviceViewSectionHeader(title: "Provisioning Profiles", sectionToggle: $showingProvisioningProfilesSection)
                    }
                }
                
                if mdCertificates != nil {
                    Section(isExpanded: $showingCertificatesSection) {
                        ForEach(mdCertificates ?? [], id: \.self) { certificate in
                            VStack {
                                HDeviceFormString(label: "Common Name", value: certificate.commonName)
                                HDeviceFormString(label: "Fingerprint", value: certificate.sha1Fingerprint, copyable: false, labelFont: .caption)
                                HDeviceFormDate(label: "Expires", value: certificate.expirationDateEpoch, labelFont: .caption)
                            }
                        }
                    } header: {
                        DeviceViewSectionHeader(title: "Certificates", sectionToggle: $showingCertificatesSection)
                    }
                }
            }
        }
        .navigationTitle(mobileDevice?.value1.name ?? mobileDevice?.value1.serialNumber ?? "Mobile Device")
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
                        showingNetworkSection = newSectionState
                        showingApplicationsSection = newSectionState
                        showingConfigProfilesSection = newSectionState
                        showingProvisioningProfilesSection = newSectionState
                        showingCertificatesSection = newSectionState
                    }
                }
                
                Button("Send Command") {}
                    .tint(colorScheme == .light ? .blue : .white)
                
                Button {
                    if mobileDevice != nil {
                        let deviceData = try! JSONEncoder().encode(mobileDevice)
                        UIPasteboard.general.string = String(data: deviceData, encoding: .utf8)
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
                let taskId = "\(client.clientId) Mobile Device \(mobileDeviceId) \(UUID())"
                
                defer { apiTask = nil }
                
                do {
                    let response = try await client.api.MobileDevicesDetailByIdGetV2(path: .init(id: mobileDeviceId))
                    let mobileDeviceData = try response.ok.body.json
                    appState.logger.info("Mobile Device Inventory API task completed: \(taskId)")
                    
                    mobileDevice = mobileDeviceData
                    
                    switch mobileDeviceData.value1._type {
                    case .ios:
                        mdModel = mobileDeviceData.value1.ios?.model
                        mdModelIdentifier = mobileDeviceData.value1.ios?.modelIdentifier
                        mdModelNumber = mobileDeviceData.value1.ios?.modelIdentifier
                        
                        mdSecurity = mobileDeviceData.value1.ios?.security
                        mdNetwork = mobileDeviceData.value1.ios?.network
                        mdApplications = mobileDeviceData.value1.ios?.applications
                        mdConfigProfiles = mobileDeviceData.value1.ios?.configurationProfiles
                        mdProvisioningProfiles = mobileDeviceData.value1.ios?.provisioningProfiles
                        mdCertificates = mobileDeviceData.value1.ios?.certificates
                        
                    case .tvos:
                        mdModel = mobileDeviceData.value1.tvos?.model
                        mdModelIdentifier = mobileDeviceData.value1.tvos?.modelIdentifier
                        mdModelNumber = mobileDeviceData.value1.tvos?.modelIdentifier
                        
                        mdConfigProfiles = mobileDeviceData.value1.tvos?.configurationProfiles
                        mdCertificates = mobileDeviceData.value1.tvos?.certificates
                        
                    case .watchos:
                        mdModel = mobileDeviceData.value1.watchos?.model
                        mdModelIdentifier = mobileDeviceData.value1.watchos?.modelIdentifier
                        mdModelNumber = mobileDeviceData.value1.watchos?.modelIdentifier
                        
                        mdSecurity = mobileDeviceData.value1.watchos?.security
                        mdApplications = mobileDeviceData.value1.watchos?.applications
                        mdConfigProfiles = mobileDeviceData.value1.watchos?.configurationProfiles
                        mdProvisioningProfiles = mobileDeviceData.value1.watchos?.provisioningProfiles
                        mdCertificates = mobileDeviceData.value1.watchos?.certificates
                        
                    case .visionos:
                        mdModel = mobileDeviceData.value1.visionos?.model
                        mdModelIdentifier = mobileDeviceData.value1.visionos?.modelIdentifier
                        mdModelNumber = mobileDeviceData.value1.visionos?.modelIdentifier
                        
                        mdSecurity = mobileDeviceData.value1.visionos?.security
                        mdApplications = mobileDeviceData.value1.visionos?.applications
                        mdConfigProfiles = mobileDeviceData.value1.visionos?.configurationProfiles
                        mdProvisioningProfiles = mobileDeviceData.value1.visionos?.provisioningProfiles
                        mdCertificates = mobileDeviceData.value1.visionos?.certificates
                    case .unknown, .none:
                        break
                    }
                } catch is CancellationError {
                    appState.logger.warning("Computer Inventory API task cancelled: \(taskId)")
                } catch {
                    appState.logger.error("\(error.localizedDescription)")
                }
            }
        }
    }
}

//#Preview {
//    MobileDeviceDetailView()
//}
