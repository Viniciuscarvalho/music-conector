//
//  HomeAdaptiveLayout.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

struct HomeAdaptiveLayout: Equatable {
    struct Sidebar: Equatable {
        let minimumWidth: CGFloat
        let idealWidth: CGFloat
        let maximumWidth: CGFloat
    }

    let usesSplitLayout: Bool
    let sidebar: Sidebar

    init(horizontalSizeClass: UserInterfaceSizeClass?, verticalSizeClass: UserInterfaceSizeClass?) {
        usesSplitLayout = horizontalSizeClass == .regular

        if verticalSizeClass == .compact {
            sidebar = Sidebar(minimumWidth: 320, idealWidth: 380, maximumWidth: 440)
        } else {
            sidebar = Sidebar(minimumWidth: 340, idealWidth: 420, maximumWidth: 500)
        }
    }
}
