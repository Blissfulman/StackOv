//
//  QuestionItemViewModel.swift
//  StackOv (HomeFlow module)
//
//  Created by Erik Basargin
//  Copyright © 2021 Erik Basargin. All rights reserved.
//

import Foundation
import struct SwiftUI.Color
import struct PageStore.QuestionItemModel

struct QuestionItemViewModel: Identifiable {
    
    enum LastUpdateType {
        case asked(Date)
        case modified(Date)
        case answered(Date)
    }
    
    let id: Int
    let title: String
    let hasAcceptedAnswer: Bool
    let answersNumber: Int
    let votesNumber: Int
    let viewsNumber: Int
    let lastUpdateType: LastUpdateType
    let backgroundColors: (top: Color, bottom: Color)
    let tags: [String]
}

// MARK: - Extensions

extension QuestionItemViewModel {
    
    var isEmpty: Bool {
        answersNumber == 0
    }
    
    var backgroundColorsList: [Color] {
        [backgroundColors.top, backgroundColors.bottom]
    }
    
    var formattedLastUpdate: String {
        let distance = lastUpdateType.date.distance(to: Date())
            
        let timeString: String
        if distance < 86400 {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            guard let distanceString = formatter.string(from: distance) else {
                return ""
            }
            timeString = "\(distanceString) ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, h:mm a"
            timeString = formatter.string(from: lastUpdateType.date)
        }

        switch lastUpdateType {
        case .answered:
            return "answered \(timeString)"
        case .asked:
            return "asked \(timeString)"
        case .modified:
            return "modified \(timeString)"
        }
    }
}

fileprivate extension QuestionItemViewModel.LastUpdateType {
    
    var date: Date {
        switch self {
        case let .answered(date):
            return date
        case let .asked(date):
            return date
        case let .modified(date):
            return date
        }
    }
}

extension QuestionItemViewModel {
    
    static func from(model: QuestionItemModel,
                     backgroundColors: (top: Color, bottom: Color)) -> QuestionItemViewModel {
        return QuestionItemViewModel(
            id: model.id,
            title: model.title,
            hasAcceptedAnswer: model.hasAcceptedAnswer,
            answersNumber: model.answerCount,
            votesNumber: model.score,
            viewsNumber: model.viewCount,
            lastUpdateType: .answered(Date()), // FIXIT: - Need update service layer
            backgroundColors: backgroundColors,
            tags: model.tags
        )
    }
}
