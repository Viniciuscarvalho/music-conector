//
//  PagedResult.swift
//  musicconector
//
//  Created by Vinicius Carvalho on 19/05/26.
//

import Foundation

struct PageRequest: Equatable, Sendable {
    let limit: Int
    let offset: Int

    init(limit: Int = 25, offset: Int = 0) {
        self.limit = max(1, min(limit, 25))
        self.offset = max(0, offset)
    }

    var next: PageRequest {
        PageRequest(limit: limit, offset: offset + limit)
    }
}

struct PagedResult<Element> {
    let items: [Element]
    let page: PageRequest
    let nextPage: PageRequest?

    init(items: [Element], page: PageRequest, nextPage: PageRequest?) {
        self.items = items
        self.page = page
        self.nextPage = nextPage
    }
}
