//
//  MdmCommands.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 9/28/24.
//

import SwiftUI

struct ComputerCommands: View {
    var body: some View {
        NavigationStack {
            Text("Commands list here")
                .navigationTitle("Send Command")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ComputerCommands()
}
