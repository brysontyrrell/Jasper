//
//  HelpQuickSearchView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 10/20/24.
//

import SwiftUI

struct HelpQuickSearchView: View {
    var body: some View {
        Form {
            Text("""
            A quick search allows you to find devices without creating a saved search first.
            
            Next to the quick search field is an icon representing the search type. Tap this to switch between computers and mobile devices.
            
            If you are on a device that shows the server pane and the device results side-by-side, typing in the quick search bar will automatically perform the search and display the results. If you are on a small device, or running the app in split view on an iPad, a magnifying glass button will appear that can be tapped to perform the search.
            
            The search will match your text against the following fields of the device inventory: the database ID (exact matching), device name, device model, serial number, and the assigned username.
            
            If you need to perform a search more than once, and you know which property you are matching against, it is recommended you create a saved search for faster results on repeat searches.
            """)
        }
        .navigationTitle("Quick Search Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HelpQuickSearchView()
}
