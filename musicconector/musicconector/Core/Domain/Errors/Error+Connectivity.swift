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

    var isAuthorizationUnavailable: Bool {
        if let catalogError = self as? MusicCatalogError {
            switch catalogError {
            case .authorizationDenied, .authorizationRestricted, .unauthorized:
                return true
            case .emptySearchTerm, .albumNotFound, .invalidCatalogData, .songNotFound:
                return false
            }
        }

        let description = String(describing: self)
        return description.contains("Unauthorized (401)")
            || description.contains("status code Unauthorized")
            || description.contains("status code: 401")
    }
}
