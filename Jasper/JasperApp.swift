//
//  JasperApp.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 8/7/24.
//

import SwiftUI

@main
struct JasperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: JamfProServer.self)
    }
}
