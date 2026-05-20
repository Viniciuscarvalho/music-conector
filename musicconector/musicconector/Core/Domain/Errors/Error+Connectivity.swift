//
//  Error+Connectivity.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

extension Error {
    var isConnectionUnavailable: Bool {
        guard let urlError = self as? URLError else { return false }

        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .cannotFindHost, .timedOut:
            return true
        default:
            return false
        }
    }
}
