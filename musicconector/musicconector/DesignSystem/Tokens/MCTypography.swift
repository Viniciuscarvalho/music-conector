//
//  MCTypography.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import SwiftUI

enum MCTypography {
    static let screenTitle = Font.system(.title2, design: .rounded, weight: .bold)
    static let navigationTitle = Font.system(.headline, design: .rounded, weight: .semibold)
    static let songTitle = Font.system(.subheadline, design: .rounded, weight: .semibold)
    static let songSubtitle = Font.system(.caption, design: .rounded, weight: .regular)
    static let body = Font.system(.subheadline, design: .rounded, weight: .regular)
    static let playerTitle = Font.system(.title2, design: .rounded, weight: .bold)
    static let playerSubtitle = Font.system(.subheadline, design: .rounded, weight: .regular)
    static let timeLabel = Font.system(.caption2, design: .rounded, weight: .regular)
}
