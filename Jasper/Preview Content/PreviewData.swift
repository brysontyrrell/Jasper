//
//  PreviewData.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 9/13/24.
//

import SwiftData
import SwiftUI

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "'\(url)'"
        } else {
            "No SQLite database found."
        }
    }
}

extension JamfProServer {
    static var preview = JamfProServer(
        hostname: "dummy.jamfcloud.com",
        port: 443,
        clientId: "2b7ea5e9-cbab-4f60-97e3-32eaefeee768",
        clientSecret: "o0dwi8E0XMaYtX760LB05csjHeJoGHKldTi4R5x7NKwLMl25gYenpMAlRDerA6G1",
        themeColor: Color("JamfBlue1"),
        isFavorite: false
    )
    
    static var previewClient = JamfProAPIClient(
        hostname: JamfProServer.preview.hostname,
        port: JamfProServer.preview.port,
        clientID: JamfProServer.preview.clientId,
        clientSecret: JamfProServer.preview.clientSecret
    )
}
