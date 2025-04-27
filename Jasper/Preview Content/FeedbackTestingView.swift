//
//  FeedbackTestingView.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 10/24/24.
//

import SwiftUI

struct FeedbackTestingView: View {
    var body: some View {
        Form {
            HDeviceFormBytes(label: "Memory", value: 196608 * 1024 * 1024)
        }
    }
}

#Preview {
    FeedbackTestingView()
}
