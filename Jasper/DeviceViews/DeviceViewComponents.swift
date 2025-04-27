//
//  DeviceViewComponents.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 9/21/24.
//

import SwiftUI

struct DeviceViewSectionHeader: View {
    let title: String
    @Binding var sectionToggle: Bool
    
    var body: some View {
        HStack {
            Text(title)
            Image(systemName: sectionToggle ? "chevron.down" : "chevron.up")
        }
        .onTapGesture {
            withAnimation {
                sectionToggle.toggle()
            }
        }
    }
}

struct HDeviceAttr: View {
    let label: String
    let value: String?
    var headline = false
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.caption)
            Text(value ?? "---")
                .font(headline ? .headline : .none)
        }
    }
}

struct HDeviceFormString: View {
    let label: String
    let value: String?
    var copyable = true
    var labelFont: Font? = nil
    
    var body: some View {
        HStack {
            Text(label)
                .font(labelFont)

            Spacer()

            Text(value ?? "---")
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .if(copyable && value != nil) { view in
                    view.contextMenu {
                        FormTextCopy(label: label, value: value!)
                    }
                }
        }
    }
}

struct HDeviceFormInt: View {
    let label: String
    let value: Int?
    var copyable = true
    var labelFont: Font? = nil
    
    var body: some View {
        HStack {
            Text(label)
                .font(labelFont)

            Spacer()

            Text(value != nil ? String(value!) : "---")
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .if(copyable && value != nil) { view in
                    view.contextMenu {
                        FormTextCopy(label: label, value: String(value!))
                    }
                }
        }
    }
}

struct HDeviceFormDate: View {
    let label: String
    let value: Date?
    var labelFont: Font? = nil
    
    var body: some View {
        HStack {
            Text(label)
                .font(labelFont)

            Spacer()

            Text(value?.formatted() ?? "---")
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

struct HDeviceFormBool: View {
    let label: String
    let value: Bool?
    var labelFont: Font? = nil
    
    var body: some View {
        HStack {
            Text(label)
                .font(labelFont)

            Spacer()

            Text(value ?? false ? "Yes" : "No")
                .foregroundStyle(.secondary)
        }
    }
}

struct HDeviceFormBytes: View {
    let label: String
    let value: Int64
    var units: ByteCountFormatStyle.Units = .all
    
    var body: some View {
        HStack {
            Text(label)
            
            Spacer()
            
            Text(formattedByteCount())
                .foregroundStyle(.secondary)
        }
    }
    
    func formattedByteCount() -> String {
        let style = ByteCountFormatStyle(
            style: .memory,
            allowedUnits: units,
            spellsOutZero: true,
            includesActualByteCount: false
        )
        return style.format(value)
    }
}

struct VDeviceAttr: View {
    let label: String
    let value: String?
    var headline = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
            Text(value ?? "---")
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

struct ComputerIcon: View {
    @Environment(AppState.self) var appState
    
    let model: String
    
    var imageName: String {
        if model.localizedStandardContains("studio") {
            return "macstudio.fill"
        } else if model.localizedStandardContains("mac mini") {
            return "macmini.fill"
        } else if model.localizedStandardContains("imac") {
            return "desktopcomputer"
        } else if model.localizedStandardContains("macbook") {
            return "macbook"
        } else {
            return "pc"
        }
    }
    
    var body: some View {
        Image(systemName: imageName)
            .foregroundColor(appState.themeColor)
    }
}

struct MobileDeviceIcon: View {
    @Environment(AppState.self) var appState
    
    let model: String
    
    var imageName: String {
        if model.localizedStandardContains("iphone") {
            return "iphone"
        } else if model.localizedStandardContains("ipad") {
            return "ipad"
        } else if model.localizedStandardContains("apple tv") {
            return "appletv.fill"
        } else if model.localizedStandardContains("vision") {
            return "visionpro"
        } else if model.localizedStandardContains("watch") {
            return "applewatch"
        } else {
            return "candybarphone"
        }
    }
    
    var body: some View {
        Image(systemName: imageName)
            .foregroundColor(appState.themeColor)
    }
}

struct InlineIcon: View {
    var name: String
    
    var body: some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .frame(height: UIFont.preferredFont(forTextStyle: .body).lineHeight)
            .foregroundStyle(.secondary)
    }
}

struct AppStoreInlineIcon: View {
    var body: some View {
        Image("AppStore")
            .resizable()
            .scaledToFit()
            .frame(height: UIFont.preferredFont(forTextStyle: .body).lineHeight)
            .opacity(0.5)
    }
}

struct FormTextCopy: View {
    var label = ""
    var value: String
    
    var body: some View {
        Button {
            UIPasteboard.general.string = value
        } label: {
            Label("Copy \(label)", systemImage: "doc.on.doc")
        }
    }
}
