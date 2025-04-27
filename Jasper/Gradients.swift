//
//  Gradients.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 8/8/24.
//

import SwiftUI

func ServerThemeGradient(baseColor: Color) -> RadialGradient {
    return RadialGradient(colors: [baseColor, baseColor.opacity(0.5)], center: .topLeading, startRadius: 30, endRadius: 200)
}
