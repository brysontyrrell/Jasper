//
//  ExportDocuments.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 10/28/24.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var exportCSV = UTType(exportedAs: "com.side7llc.Jasper.csv")
}

extension UTType {
    static var exportJson = UTType(exportedAs: "com.side7llc.Jasper.json")
}

func formattedDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
    return dateFormatter.string(from: Date())
}

struct ComputersExportCSV {
    var computers: [Components.Schemas.ComputerInventory]
    
    func convertToCSV() -> Data {
        var csvText = "ID,Name,Serial Number,Asset Tag,Username,Email,Model,Model Identifier,Management ID\n"
        
        for result in computers {
            let id = result.id ?? ""
            let name = result.general?.name ?? ""
            let serialNumber = result.hardware?.serialNumber ?? ""
            let assetTag = result.general?.assetTag ?? ""
            let username = result.userAndLocation?.username ?? ""
            let email = result.userAndLocation?.email ?? ""
            let model = result.hardware?.model ?? ""
            let modelId = result.hardware?.modelIdentifier ?? ""
            let managementId = result.general?.managementId ?? ""
        
            csvText += "\"\(id)\",\"\(name)\",\"\(serialNumber)\",\"\(assetTag)\",\"\(username)\",\"\(email)\",\"\(model)\",\"\(modelId)\",\"\(managementId)\"\n"
        }
        
        return csvText.data(using: .utf8)!
    }
}

extension ComputersExportCSV: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { export in
            print("CSV DATA EXPORT")
            return export.convertToCSV()
        }
        .suggestedFileName("Computers Export \(formattedDate()).csv")
        
//        FileRepresentation(exportedContentType: .commaSeparatedText) { export in
//            print("CSV FILE EXPORT")
//            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("Computers Export \(formattedDate()).csv")
//            try export.convertToCSV().write(to: fileURL)
//            print(fileURL)
//            return SentTransferredFile(fileURL)
//        }
//        .suggestedFileName("Computers Export \(formattedDate()).csv")
    }
}

struct ComputersExportJSON: Codable {
    var computers: [Components.Schemas.ComputerInventory]
}

extension ComputersExportJSON: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
            .suggestedFileName("Computers Export \(formattedDate()).json")
    }
}

struct MobileDevicesExportCSV {
    var mobileDevices: [UnifiedMobileDeviceResponse]
    
    func convertToCSV() -> Data {
        var csvText = "ID,Name,Serial Number,Asset Tag,Username,Email,Model,Model Identifier\n"
        
        for result in mobileDevices {
            let id = result.mobileDeviceId
            let name = result.general?.displayName ?? ""
            let serialNumber = result.hardware?.serialNumber ?? ""
            let assetTag = result.general?.assetTag ?? ""
            let username = result.userAndLocation?.username ?? ""
            let email = result.userAndLocation?.emailAddress ?? ""
            let model = result.hardware?.model ?? ""
            let modelId = result.hardware?.modelIdentifier ?? ""
        
            csvText += "\"\(id)\",\"\(name)\",\"\(serialNumber)\",\"\(assetTag)\",\"\(username)\",\"\(email)\",\"\(model)\",\"\(modelId)\"\n"
        }
        
        return csvText.data(using: .utf8)!
    }
}

extension MobileDevicesExportCSV: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .commaSeparatedText) { export in
            print("CSV DATA EXPORT")
            return export.convertToCSV()
        }
        .suggestedFileName("Mobile Devices \(formattedDate()).csv")
    }
}

struct MobileDevicesExportJSON: Codable {
    var mobileDevices: [UnifiedMobileDeviceResponse]
}

extension MobileDevicesExportJSON: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
            .suggestedFileName("Mobile Devices Export \(formattedDate()).json")
    }
}
