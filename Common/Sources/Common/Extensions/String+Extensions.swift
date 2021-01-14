//
//  String+Extensions.swift
//  This source file is part of the StackOv open source project
//

import Foundation

public extension String {
    
    init?(htmlString: String) {
        guard let data = htmlString.data(using: .utf8) else { return nil }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
    
    var urlQueryAllowed: String? {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
