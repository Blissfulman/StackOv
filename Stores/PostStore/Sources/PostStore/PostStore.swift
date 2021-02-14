//
//  PostStore.swift
//  StackOv (PostStore module)
//
//  Created by Erik Basargin
//  Copyright © 2021 Erik Basargin. All rights reserved.
//

import Foundation
import Combine
import StackexchangeNetworkService
import struct PageStore.QuestionModel

public final class PostStore: ObservableObject {
    
    // MARK: - Nested types
    
    public enum State {
        case unknown
        case emptyContent
        case content(Void)
        case loading
        case error(Error)
    }
    
    public enum LoadingType {
        case reload
        case next
    }
    
    // MARK: - Substores & Services
    
    // MARK: - Public properties
    
    @Published public private(set) var state: State = .unknown
    public let questionModel: QuestionModel

    // MARK: - Initialization and deinitialization
    
    public init(model: QuestionModel) {
        self.questionModel = model
    }
}

// MARK: - Actions

public extension PostStore {

    func loadAnswers(_ type: LoadingType = .reload) {
        #if DEBUG
        state = .content(())
        #endif
    }
}
