//
//  LoadQuestionRequests.swift
//  StackOv (StackexchangeNetworkService module)
//
//  Created by Erik Basargin
//  Copyright © 2021 Erik Basargin. All rights reserved.
//

import Network
import Combine
import Foundation
import DataTransferObjects

public extension Request where Endpoint == StackexchangeNetworkService.LoadQuestion, Output == PostsEntry<QuestionEntry> {
    
    func callAsFunction(questionId id: Int) -> AnyPublisher<Output, Error> {
        let systemParameters: [URLQueryItem] = [
            URLQueryItem(name: "key", value: StackexchangeNetworkService.Constants.quotaKey),
            URLQueryItem(name: "filter", value: StackexchangeNetworkService.Constants.questionFilter),
            URLQueryItem(name: "site", value: "stackoverflow")
        ]
        
        do {
            let request = try buildURLRequest(parameters: systemParameters, arguments: [id])
            return URLSession.shared.dataTaskPublisher(for: request)
                .tryCatchHTTPError()
                .map { $0.data }
                .decode(type: Output.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
