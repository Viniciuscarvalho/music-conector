//
//  SplashAsset.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 21/05/26.
//

import SwiftUI

enum SplashAsset: String, Equatable {
    case phone = "Splash"
    case pad = "Splash-iPad"

    init(horizontalSizeClass: UserInterfaceSizeClass?) {
        if horizontalSizeClass == .regular {
            self = .pad
        } else {
            self = .phone
        }
    }
}
