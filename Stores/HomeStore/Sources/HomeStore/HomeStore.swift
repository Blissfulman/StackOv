//
//  HomeStore.swift
//  This source file is part of the StackOv open source project
//

import Foundation
import Combine
import StackexchangeService

public final class HomeStore: ObservableObject {
    
    // MARK: - Nested types
    
    enum State {
        case unknown
        case emptyContent
        case content([QuestionItemModel])
        case loading
        case error(Error)
    }
    
    enum LoadingState {
        case loadQuestions(page: Int, pageSize: Int)
        case searchQuestion(page: Int, pageSize: Int)
    }
    
    enum LoadingStep {
        case reload
        case next
    }
    
    // MARK: - Substores
    
//    private(set) lazy var searchStore = SearchStore()
//    private(set) lazy var questionStore = QuestionStore()
    
    @Published private(set) var state: State = .unknown
    @Published private(set) var hasMore: Bool = true
    @Published private(set) var nextLoading: Bool = false
    
    private lazy var service = StackexchangeService()
    
    private var loadingState: LoadingState = .loadQuestions(page: 1, pageSize: 30)
    private var currentQuery: String = ""
    
    private var cancelBag: Set<AnyCancellable> = []
    private var loadingProcess: AnyCancellable?
    private var searchProcess: AnyCancellable?
    
    // MARK: - Initializing and deinitializing
    
    init() {
//        subsctibeToSearchStore()
    }
    
    deinit {
        cancelSearchProcess()
        cancelLoadingProcess()
        cancelBag.forEach { $0.cancel() }
    }
    
    // MARK: - Configurations
    
//    func subsctibeToSearchStore() {
//        searchStore.$query
//            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .combineLatest(searchStore.$isEditing)
//            .sink { [unowned self] (query, isEditing) in
//                self.checkSearchParams(query: query, isEditing: isEditing)
//            }
//            .store(in: &cancelBag)
//    }
    
    // MARK: - Methods
    
    func cancelSearchProcess() {
        searchProcess?.cancel()
        searchProcess = nil
    }
    
    func cancelLoadingProcess() {
        loadingProcess?.cancel()
        loadingProcess = nil
    }
    
    func checkSearchParams(query: String, isEditing: Bool) {
        if query.isEmpty, currentQuery != query, !isEditing {
            hasMore = true
            currentQuery = ""
            cancelSearchProcess()
            loadQuestions()
            return
        }
        if !query.isEmpty, currentQuery != query {
            hasMore = true
            currentQuery = query
            cancelLoadingProcess()
            searchQuestions()
        }
    }
    
    func itemWasShowed(id: Int) {
        guard state.content.last?.id == id else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            switch self.loadingState {
            case .loadQuestions:
                self.loadQuestions(.next)
            case .searchQuestion:
                self.searchQuestions(.next)
            }
        }
    }
    
    func loadQuestions(_ step: LoadingStep = .reload) {
        guard loadingProcess == nil, hasMore else {
            return
        }
        switch step {
        case .reload:
            state = .loading
            loadingState = .loadQuestions(page: 1, pageSize: 30)
        case .next:
            loadingState += 1
            nextLoading = true
        }
        loadingProcess = service.loadQuestions(page: loadingState.page, pageSize: loadingState.pageSize)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [unowned self] completion in
                self.cancelLoadingProcess()
                self.nextLoading = false
                guard case let .failure(error) = completion else {
                    return
                }
                self.state = .error(error)
            }) { [unowned self] data in
                let questions = data.items.map { QuestionItemModel.from(dto: $0) }
                switch step {
                case .reload:
                    self.state = questions.isEmpty ? .emptyContent : .content(questions)
                case .next:
                    let content = self.state.content + questions
                    self.state = content.isEmpty ? .emptyContent : .content(content)
                }
                self.hasMore = data.hasMore
            }
    }
    
    func searchQuestions(_ step: LoadingStep = .reload) {
        guard searchProcess == nil, hasMore else {
            return
        }
        switch step {
        case .reload:
            loadingState = .searchQuestion(page: 1, pageSize: 30)
        case .next:
            loadingState += 1
            nextLoading = true
        }
        searchProcess = service.searchQuestions(query: currentQuery, page: loadingState.page, pageSize: loadingState.pageSize)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [unowned self] completion in
                self.cancelSearchProcess()
                self.nextLoading = false
                guard case let .failure(error) = completion else {
                    return
                }
                self.state = .error(error)
            }) { [unowned self] data in
                let questions = data.items.map { QuestionItemModel.from(dto: $0) }
                switch step {
                case .reload:
                    self.state = questions.isEmpty ? .emptyContent : .content(questions)
                case .next:
                    let content = self.state.content + questions
                    self.state = content.isEmpty ? .emptyContent : .content(content)
                }
                self.hasMore = data.hasMore
            }
    }
}

// MARK: - Extensions

extension HomeStore.State {
    var content: [QuestionItemModel] {
        if case let .content(questions) = self { return questions }
        return []
    }
    
    var error: Error? {
        if case let .error(error) = self { return error }
        return nil
    }
    
    var isUnknown: Bool {
        if case .unknown = self { return true }
        return false
    }
}

fileprivate extension HomeStore.LoadingState {
    var page: Int {
        switch self {
        case let .loadQuestions(page, _):
            return page
        case let .searchQuestion(page, _):
            return page
        }
    }
    
    var pageSize: Int {
        switch self {
        case let .loadQuestions(_, pageSize):
            return pageSize
        case let .searchQuestion(_, pageSize):
            return pageSize
        }
    }
    
    static func +=(lhs: inout Self, rhs: Int) {
        switch lhs {
        case let .loadQuestions(page, pageSize):
            lhs = .loadQuestions(page: page + rhs, pageSize: pageSize)
        case let .searchQuestion(page, pageSize):
            lhs = .searchQuestion(page: page + rhs, pageSize: pageSize)
        }
    }
}

