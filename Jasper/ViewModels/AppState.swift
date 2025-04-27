//
//  AppViewModel.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 9/24/24.
//

import os.log
import SwiftUI

@Observable
class AppState {
    let logger = Logger(subsystem: "com.side7llc.Jasper", category: "app")
    
    var reportedHorizontalSizeClass: UserInterfaceSizeClass?
    
    var themeColor = Color.secondary
    
    var pageSize: Int {
        // If not set, the default value is '100'
        if UserDefaults.standard.object(forKey: "pageSize") == nil {
            return 100
        } else {
            return UserDefaults.standard.integer(forKey: "pageSize")
        }
    }
    
    var includeUserAndLocationInSearches: Bool {
        // If not set, the default value is 'true'
        if UserDefaults.standard.object(forKey: "includeUserAndLocationInSearches") == nil {
            return true
        } else {
            return UserDefaults.standard.bool(forKey: "includeUserAndLocationInSearches")
        }
    }
    
    func setThemeColor(_ themeColorRGB: ThemeColorRGB) {
        themeColor = Color(
            red: themeColorRGB.red,
            green: themeColorRGB.green,
            blue: themeColorRGB.blue
        )
    }
}
