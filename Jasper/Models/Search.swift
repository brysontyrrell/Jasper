//
//  ComputerSearch.swift
//  Jasper
//
//  Created by Bryson Tyrrell on 9/17/24.
//

import SwiftData

@Model
class Search {
    var name: String
    var searchType: SearchType
    var sort: [SortOption]
    var filters: [Filter]
    
    var server: JamfProServer?
    
    var sortExpression: [String] {
        sort.map { $0.expression }
    }
    
    var filterExpression: String {
        String(filters.map { $0.expression }.joined().dropLast())
    }
    
    init(name: String, searchType: SearchType, sort: [SortOption]? = nil, filters: [Filter]? = nil) {
        self.name = name
        self.searchType = searchType
        
        if let sort {
            // TODO: Sort field validation
            self.sort = sort
        } else {
            switch searchType {
            case .computer:
                self.sort = [SortOption(field: "id", direction: .asc)]
            case .mobileDevice:
                self.sort = [SortOption(field: "deviceId", direction: .asc)]
            }
        }
        
        // TODO: Filter field validation
        self.filters = filters ?? []
    }
    
    static var allComputers: Search {
        .init(name: "All Computers", searchType: .computer)
    }
    
    static var allMobileDevices: Search {
        .init(name: "All Mobile Devices", searchType: .mobileDevice)
    }
}

enum SearchType: String, Codable {
    case computer = "Computer"
    case mobileDevice = "Mobile Device"
}

struct SortOption: Codable {
    let field: String
    let direction: SortDirection
    
    var expression: String {
        "\(field):\(direction.rawValue)"
    }
}

enum SortDirection: String, Codable {
    case asc = "asc"
    case desc = "desc"
}

struct Filter: Codable {
    let field: String
    let op: FilterOp
    let value: String
    let andOr: FilterAndOr
    
    var expression: String {
        "\(field)\(op.rawValue)'\(value)'\(andOr.rawValue)"
    }
}

enum FilterAndOr: String, Codable {
    case and = ";"
    case or = ","
}

enum FilterOp: String, Codable, CaseIterable {
    case equal_to = "=="
    case not_equal_to = "!="
    case less_than = "<"
    case less_than_or_equal_to = "<="
    case greater_than = ">"
    case greater_than_or_equal_to = ">="
}
