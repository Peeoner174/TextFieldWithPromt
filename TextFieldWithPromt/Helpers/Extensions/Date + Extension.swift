//
//  Date + Extension.swift
//  TextFieldWithPromt
//
//  Created by MSI on 02.06.2020.
//  Copyright © 2020 MSI. All rights reserved.
//

import Foundation

extension Date {
    public enum DateFormatType: String {
        case isoDateTime = "yyyy'-'MM'-'dd'T'HH':'mm':'ss"
        case dotFormatDate = "yyyy'.'MM'.'dd'"
    }
    
    init?(string: String, format: DateFormatType) {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = format.rawValue
          guard let date = dateFormatter.date(from: string) else { return nil }
          
          self.init(timeInterval: 0, since: date)

      }
    
    func toString(_ format: DateFormatType) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }
}
