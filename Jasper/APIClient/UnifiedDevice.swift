//
//  UnifiedDevice.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 10/9/24.
//

import Foundation

struct UnifiedMobileDeviceInventorySearchResults: Codable, Hashable {
    var totalCount: Int?
    var results: [UnifiedMobileDeviceResponse]?
}

struct UnifiedMobileDeviceResponse: Codable, Hashable {
    // MobileDeviceInventory - shared properties (also 'Unknown')
    var mobileDeviceId: String // This will always exist (!)
    var deviceType: String
    
    var general: Components.Schemas.MobileDeviceGeneral?
    var hardware: Components.Schemas.MobileDeviceHardware?
    var userAndLocation: Components.Schemas.MobileDeviceUserAndLocation?
    
    init(device: Components.Schemas.MobileDeviceResponse) {
        switch device {
        case .iOS(let iOSDevice):
            self.mobileDeviceId = iOSDevice.value1.mobileDeviceId!
            self.deviceType = iOSDevice.value1.deviceType
            
            self.general = iOSDevice.value2.general?.value1
            self.hardware = iOSDevice.value1.hardware
            self.userAndLocation = iOSDevice.value1.userAndLocation
            

        case .tvOS(let tvOSDevice):
            self.mobileDeviceId = tvOSDevice.value1.mobileDeviceId!
            self.deviceType = tvOSDevice.value1.deviceType
            
            self.general = tvOSDevice.value2.general?.value1
            self.hardware = tvOSDevice.value1.hardware
            self.userAndLocation = tvOSDevice.value1.userAndLocation

        case .watchOS(let watchOSDevice):
            self.mobileDeviceId = watchOSDevice.value1.mobileDeviceId!
            self.deviceType = watchOSDevice.value1.deviceType
            
            self.general = watchOSDevice.value2.general?.value1
            self.hardware = watchOSDevice.value1.hardware
            self.userAndLocation = watchOSDevice.value1.userAndLocation

        case .Unknown(let unknownDevice):
            // MobileDeviceInventory properties only
            self.mobileDeviceId = unknownDevice.mobileDeviceId!
            self.deviceType = unknownDevice.deviceType
            
            // No 'general' property
            self.hardware = unknownDevice.hardware
            self.userAndLocation = unknownDevice.userAndLocation
        }
    }
}
