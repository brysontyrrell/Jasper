//
//  AddSearchView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 9/18/24.
//

import SwiftData
import SwiftUI

struct AddSearchView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Environment(AppState.self) var appState
    
    var server: JamfProServer
    
    @State private var searchType = SearchType.computer
    @State private var searchName = ""
    
    @State private var sortField = computerSortFields[0]
    @State private var sortDirection: SortDirection = .asc
    
    @State private var filterField = computerFilterFields[0]
    @State private var filterOp: FilterOp = .equal_to
    @State private var filterValue = ""
    @State private var filterAndOr: FilterAndOr = .and
    @State private var filters = [Filter]()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Type")
                            .font(.headline)
                        Spacer()
                        Picker("Search type", selection: $searchType) {
                            ForEach([SearchType.computer, SearchType.mobileDevice], id: \.self) { option in
                                Text(option.rawValue)
                            }
                        }
                        .labelsHidden()
                    }
                    
                    HStack {
                        Text("Name")
                            .font(.headline)
                        Spacer()
                        TextField("New search", text: $searchName)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Sorting Options") {
                    HStack {
                        Text("Sort By")
                            .font(.headline)
                        
                        Spacer()
                        
                        Picker("Sort field", selection: $sortField) {
                            switch searchType {
                            case .computer:
                                ForEach(computerSortFields, id: \.self) { field in
                                    Text(field)
                                }
                            case .mobileDevice:
                                ForEach(mobileDeviceSortField, id: \.self) { field in
                                    Text(field)
                                }
                            }
                        }
                        .labelsHidden()
                        
                        Picker("Sort direction", selection: $sortDirection) {
                            ForEach([SortDirection.asc, SortDirection.desc], id: \.self) { option in
                                Text(option.rawValue)
                            }
                        }
                        .labelsHidden()
                    }
                }
                
                Section("Filtering Options") {
                    HStack {
                        Text("Field")
                            .font(.headline)
                        Spacer()
                        Picker("Filter field", selection: $filterField) {
                            switch searchType {
                            case .computer:
                                ForEach(computerFilterFields, id: \.self) { field in
                                    Text(field)
                                }
                            case .mobileDevice:
                                ForEach(mobileDeviceFilterFields, id: \.self) { field in
                                    Text(field)
                                }
                            }
                        }
                        .labelsHidden()
                    }
                    
                    HStack {
                        Text("Operation")
                            .font(.headline)
                        Spacer()
                        Picker("Filter operation", selection: $filterOp) {
                            ForEach(FilterOp.allCases, id: \.self) { option in
                                Text(String(describing: option).replacingOccurrences(of: "_", with: " "))
                            }
                        }
                        .labelsHidden()
                    }
                    
                    HStack {
                        Text("Value")
                            .font(.headline)
                        Spacer()
                        TextField("Filter value", text: $filterValue)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("and | or")
                            .font(.headline)
                        Spacer()
                        Picker("And Or", selection: $filterAndOr) {
                            ForEach([FilterAndOr.and, FilterAndOr.or], id: \.self) { option in
                                Text(String(describing: option))
                            }
                        }
                        .labelsHidden()
                    }
                        
                    Button("Add Filter") {
                        filters.append(
                            Filter.init(
                                field: filterField,
                                op: filterOp,
                                value: filterValue,
                                andOr: .and
                            )
                        )
                        
                        switch searchType {
                        case .computer:
                            filterField = computerFilterFields[0]
                        case .mobileDevice:
                            filterField = mobileDeviceFilterFields[0]
                        }

                        filterOp = .equal_to
                        filterValue = ""
                    }
                    .disabled(filterValue.isEmpty)
                }
                .listRowSeparator(.hidden)
                
                // Note: Because a binding is passed to the list, a binding is passed to the closure
                Section("Filters") {
                    List($filters, id: \.expression, editActions: [.move, .delete]) { $filter in
                        HStack {
                            Text("Filter")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(filter.field)
                            
                            Text(filter.op.rawValue)
                                .font(.caption)
                            
                            Text(filter.value)
                            
                            Text(String(describing: filter.andOr))
                                .font(.footnote)
                        }
                    }
                }
            }
            .navigationTitle("Add Search")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: searchType) {
                // Reset form values back to defaults for type
                switch searchType {
                case .computer:
                    sortField = computerSortFields[0]
                    filterField = computerFilterFields[0]
                case .mobileDevice:
                    sortField = mobileDeviceSortField[0]
                    filterField = mobileDeviceFilterFields[0]
                }
                sortDirection = .asc
                filterOp = .equal_to
                filterValue = ""
                filterAndOr = .and
                filters = []
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let newSearch = Search(
                            name: searchName,
                            searchType: searchType,
                            sort: [SortOption(field: sortField, direction: sortDirection)],
                            filters: filters
                        )
                        print("\(newSearch)")
                        server.searches.append(newSearch)
                        dismiss()
                    }
                    .disabled(searchName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

let computerSortFields = [
    "id",
    "udid",
    
    "general.name",
    "general.assetTag",
    "general.jamfBinaryVersion",
    "general.lastContactTime",
    "general.lastEnrolledDate",
    "general.lastCloudBackupDate",
    "general.reportDate",
    "general.remoteManagement.managementUsername",
    "general.mdmCertificateExpiration",
    "general.platform",
    
    "hardware.make",
    "hardware.model",
    
    "operatingSystem.build",
    "operatingSystem.supplementalBuildVersion",
    "operatingSystem.rapidSecurityResponse",
    "operatingSystem.name",
    "operatingSystem.version",
    
    "userAndLocation.realname"
]

let computerFilterFields = [
    "id",
    "udid",

    "general.name",
    "general.assetTag",
    "general.jamfBinaryVersion",
    "general.lastContactTime",
    "general.lastEnrolledDate",
    "general.reportDate",
    "general.managementId",
    "general.remoteManagement.managed",
    "general.mdmCapable.capable",
    "general.mdmCertificateExpiration",
    "general.supervised",
    "general.userApprovedMdm",
    "general.declarativeDeviceManagementEnabled",

    "hardware.model",
    "hardware.modelIdentifier",
    "hardware.serialNumber",

    "operatingSystem.fileVault2Status",
    "operatingSystem.build",
    "operatingSystem.version",
    "operatingSystem.supplementalBuildVersion",
    "operatingSystem.rapidSecurityResponse",

    "security.activationLockEnabled",
    "security.recoveryLockEnabled",
    "security.firewallEnabled",

    "userAndLocation.buildingId",
    "userAndLocation.departmentId",
    "userAndLocation.room",
    "userAndLocation.username"
]

let mobileDeviceSortField = [
    "mobileDeviceId",
    "deviceId",
    "displayName",
    "osVersion",
    "lastInventoryUpdateDate",
    "lastEnrolledDate",
    "mdmProfileExpirationDate",
    "model",
    "modelIdentifier",
    "fullName",
    "username",

    "assetTag",
    "availableSpaceMb",
    "batteryLevel",
    "bluetoothMacAddress",
    "capacityMb",
    "lostModeEnabledDate",
    "devicePhoneNumber",
    "enrollmentSessionTokenValid",
    "osBuild",
    "osSupplementalBuildVersion",
    "osRapidSecurityResponse",
    "ipAddress",
    "lastBackupDate",
    "lastCloudBackupDate",
    "modelNumber",
    "timeZone",
    "udid",
    "usedSpacePercentage",
    "building",
    "department",
    "emailAddress",
    "position",
    "room",
    "leaseExpirationDate",
    "lifeExpectancyYears",
    "poDate",
    "poNumber",
    "warrantyExpirationDate"
]

let mobileDeviceFilterFields = [
    "mobileDeviceId",
    "displayName",
    "model",
    "modelIdentifier",
    "modelNumber",
    "lastInventoryUpdateDate",
    "building",
    "department",
    "emailAddress",
    "fullName",
    "userPhoneNumber",
    "position",
    "room",
    "username",
    
    "airPlayPassword",
    "appAnalyticsEnabled",
    "assetTag",
    "availableSpaceMb",
    "batteryLevel",
    "bluetoothLowEnergyCapable",
    "bluetoothMacAddress",
    "capacityMb",
    "declarativeDeviceManagementEnabled",
    "deviceId",
    "deviceLocatorServiceEnabled",
    "devicePhoneNumber",
    "diagnosticAndUsageReportingEnabled",
    "doNotDisturbEnabled",
    "exchangeDeviceId",
    "cloudBackupEnabled",
    "osBuild",
    "osSupplementalBuildVersion",
    "osVersion",
    "osRapidSecurityResponse",
    "ipAddress",
    "itunesStoreAccountActive",
    "languages",
    "locales",
    "locationServicesForSelfServiceMobileEnabled",
    "lostModeEnabled",
    "managed",
    "modemFirmwareVersion",
    "quotaSize",
    "residentUsers",
    "serialNumber",
    "sharedIpad",
    "supervised",
    "tethered",
    "timeZone",
    "udid",
    "usedSpacePercentage",
    "wifiMacAddress",
    "appleCareId",
    "lifeExpectancyYears",
    "poNumber",
    "purchasePrice",
    "purchasedOrLeased",
    "purchasingAccount",
    "purchasingContact",
    "vendor",
    "activationLockEnabled",
    "blockEncryptionCapable",
    "dataProtection",
    "fileEncryptionCapable",
    "passcodeCompliant",
    "passcodeCompliantWithProfile",
    "passcodeLockGracePeriodEnforcedSeconds",
    "passcodePresent",
    "personalDeviceProfileCurrent",
    "carrierSettingsVersion",
    "currentCarrierNetwork",
    "currentMobileCountryCode",
    "currentMobileNetworkCode",
    "dataRoamingEnabled",
    "eid",
    "network",
    "homeMobileCountryCode",
    "homeMobileNetworkCode",
    "iccid",
    "imei",
    "imei2",
    "meid",
    "personalHotspotEnabled",
    "roaming"
]

#if DEBUG
#Preview {
    AddSearchView(server: JamfProServer.preview)
}
#endif
