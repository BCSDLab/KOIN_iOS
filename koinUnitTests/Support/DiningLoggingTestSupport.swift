//
//  DiningLoggingTestSupport.swift
//  koinUnitTests
//
//  Created by 이은지 on 8/17/26.
//

import Combine
import UIKit
@testable import koin

struct DiningLoggedEvent: Equatable {
    let label: String
    let category: String
    let value: String

    init(
        _ label: String,
        _ category: String,
        _ value: String
    ) {
        self.label = label
        self.category = category
        self.value = value
    }
}

final class DiningInputRecorder {

    private(set) var inputs: [DiningViewModel.Input] = []
    private var cancellable: AnyCancellable?

    init(_ viewController: DiningViewController) {
        cancellable = viewController.inputSubject.sink { [weak self] input in
            self?.inputs.append(input)
        }
    }

    var loggedEvents: [DiningLoggedEvent] {
        inputs.compactMap { input in
            guard case let .logEvent(label, category, value) = input else { return nil }
            return DiningLoggedEvent(label.rawValue, category.rawValue, "\(value)")
        }
    }

    var inputKinds: [String] {
        inputs.map { input in
            switch input {
            case .updateDisplayDateTime: "updateDisplayDateTime"
            case .shareMenuList: "shareMenuList"
            case .determineInitDate: "determineInitDate"
            case .changeNoti: "changeNoti"
            case .fetchNotiList: "fetchNotiList"
            case .logEvent: "logEvent"
            case .logEventWithSessionId: "logEventWithSessionId"
            }
        }
    }
}

@MainActor
final class DiningLoggingTestBed {

    let sut: DiningViewController
    let recorder: DiningInputRecorder

    init() {
        sut = DiningViewController(
            viewModel: DiningViewModel(
                fetchDiningListUseCase: StubFetchDiningListUseCase(),
                logAnalyticsEventUseCase: StubLogAnalyticsEventUseCase(),
                dateProvder: StubDateProvider(),
                shareMenuListUseCase: StubShareMenuListUseCase(),
                changeNotiUseCase: StubChangeNotiUseCase(),
                fetchNotiListUsecase: StubFetchNotiListUseCase(),
                changeNotiDetailUseCase: StubChangeNotiDetailUseCase()
            )
        )
        
        sut.loadViewIfNeeded()
        recorder = DiningInputRecorder(sut)
    }

    func selectSegment(_ index: Int) {
        sut.diningTypeSegmentControl.selectedSegmentIndex = index
    }

    func tapSegment(_ index: Int) {
        selectSegment(index)
        sut.diningTypeSegmentControl.sendActions(for: .valueChanged)
    }

    func swipe(_ direction: UISwipeGestureRecognizer.Direction) {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = direction
        sut.handleSwipe(gesture)
    }

    func pullToRefresh() {
        sut.diningListCollectionView.refreshControl?.sendActions(for: .valueChanged)
    }

    func tapMenuImage(place: String) {
        sut.diningListCollectionView.imageTapPublisher.send((UIImage(), place))
    }

    func tapShareButton() {
        sut.diningListCollectionView.shareButtonPublisher.send(DiningFixture.item().toShareDiningItem())
    }

    func scrollDiningList() {
        sut.diningListCollectionView.logScrollPublisher.send(())
    }

    func tapCafeteriaInfoButton() {
        guard let item = sut.navigationItem.rightBarButtonItem,
              let action = item.action,
              let target = item.target as? NSObject
        else { return }
        target.perform(action)
    }
}
