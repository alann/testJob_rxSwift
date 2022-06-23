//
//  Date + Extension.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import Foundation

extension Date {
    
    func getFormattedDateForUser() -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "dd.MM.yyyy"
        return dateformat.string(from: self)
    }
    
    func getFormattedDateForIInput() -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = "dd-MM-yyyy"
        return dateformat.string(from: self)
    }
}
