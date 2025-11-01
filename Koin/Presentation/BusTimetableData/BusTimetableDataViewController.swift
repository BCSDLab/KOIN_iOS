//
//  BusTimetableDataViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/5/24.
//

import Combine
import UIKit
import SnapKit

final class BusTimetableDataViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    private var inputSubject: PassthroughSubject<BusTimetableDataViewModel.Input, Never> = .init()
    private let viewModel: BusTimetableDataViewModel
    
    // MARK: - UI Components
    private var shuttleRouteTypeLabel = UILabel().then {
        $0.layer.cornerRadius = 4
        $0.layer.masksToBounds = true
        $0.font = .appFont(.pretendardRegular, size: 11)
        $0.textAlignment = .center
        $0.textColor = .appColor(.neutral0)
    }
    
    private let busTimetablePlaceLabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 20)
        $0.textColor = .appColor(.neutral800)
        $0.textAlignment = .left
    }
    
    private let subBusTimetablePlaceLabel = UILabel().then {
        $0.font = .appFont(.pretendardRegular, size: 12)
        $0.textColor = .appColor(.neutral500)
        $0.textAlignment = .left
    }
    
    private let incorrectBusInfoButton = UIButton().then {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .incorrectInfo)
        let title = AttributedString("정보가 정확하지 않나요?", attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardRegular, size: 12),
            .foregroundColor: UIColor.appColor(.neutral500)
        ]))
        configuration.attributedTitle = title
        configuration.imagePadding = 4
        configuration.contentInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)
        $0.configuration = configuration
    }
    
    private let busTimetableBorderView = UIView().then {
        $0.backgroundColor = .appColor(.neutral400)
    }
    
    private let busTimetableSeparateView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    private let oneBusTimetableDataTableView = OneBusTimetableTableView(frame: .zero, style: .grouped)
    
    private let manyBusTimetableDataTableView = ManyBusTimetableTableView(frame: .zero, style: .grouped)
    
    private let manyBusTimetableDataCollectionView = ManyBusTimetableCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.collectionViewLayout = layout
    }
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let segmentControl = UISegmentedControl().then {
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.insertSegment(withTitle: "등교", at: 0, animated: true)
        $0.insertSegment(withTitle: "하교", at: 1, animated: true)
        $0.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.neutral500), NSAttributedString.Key.font: UIFont.appFont(.pretendardRegular, size: 16)], for: .normal)
        $0.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.appColor(.primary500), NSAttributedString.Key.font: UIFont.appFont(.pretendardBold, size: 16)], for: .selected)
        $0.layer.masksToBounds = false
        $0.selectedSegmentIndex = 0
    }
    
    private let shadowView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral400)
        $0.layer.applySketchShadow(color: .appColor(.neutral800), alpha: 0.02, x: 0, y: 1, blur: 1, spread: 0)
    }
    
    private let selectedUnderlineView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.primary500)
    }
    
    private let headerColorView = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral100)
    }
    
    // MARK: - Initialization
    init(viewModel: BusTimetableDataViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        segmentControl.addTarget(self, action: #selector(changeSegmentControl), for: .valueChanged)
        incorrectBusInfoButton.addTarget(self, action: #selector(tapIncorrentInfoButton), for: .touchUpInside)
        bind()
        inputSubject.send(.getBusTimetable(.manyRoute))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
    }
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateBusRoute(timetable, shuttleTimetableType):
                self?.updateShuttleBusTimetable(timetable: timetable, shuttleTimetableType: shuttleTimetableType)
            }
        }.store(in: &subscriptions)
        
        manyBusTimetableDataTableView.contentHeightPublisher.sink { [weak self] height in
            DispatchQueue.main.async {
                self?.contentView.snp.updateConstraints {
                    $0.height.equalTo(height + 30)
                }
                self?.busTimetableSeparateView.snp.updateConstraints {
                    $0.height.equalTo(height - 20)
                }
            }
        }.store(in: &subscriptions)
        
        manyBusTimetableDataCollectionView.contentWidthPublisher
            .sink { [weak self] width in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    let headerWidth = UIScreen.main.bounds.width - width - self.manyBusTimetableDataTableView.bounds.width
                    if headerWidth > 0 {
                        self.headerColorView.snp.updateConstraints {
                            $0.width.equalTo(headerWidth)
                        }
                    }
                    else {
                        self.headerColorView.snp.updateConstraints {
                            $0.width.equalTo(0)
                        }
                    }
                }
            }.store(in: &subscriptions)
        
        oneBusTimetableDataTableView.tapIncorrectButtonPublisher.sink { [weak self] in
            let routeValue = "\(self?.shuttleRouteTypeLabel.text ?? "")_\(self?.busTimetablePlaceLabel.text ?? "")"
            self?.inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.errorFeedbackButton, .click, routeValue))
            if let url = URL(string: "https://docs.google.com/forms/d/1GR4t8IfTOrYY4jxq5YAS7YiCS8QIFtHaWu_kE-SdDKY"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }.store(in: &subscriptions)
    }
}

extension BusTimetableDataViewController {
    @objc private func changeSegmentControl(sender: UISegmentedControl) {
        moveUnderLineView()
        let shuttleTimetableType: ShuttleTimetableType
        switch sender.selectedSegmentIndex {
        case 0:
            shuttleTimetableType = .goSchool
        default:
            shuttleTimetableType = .dropOffSchool
        }
        inputSubject.send(.getBusTimetable(shuttleTimetableType))
    }
    
    @objc private func tapIncorrentInfoButton() {
        let routeValue = "\(shuttleRouteTypeLabel.text ?? "")_\(busTimetablePlaceLabel.text ?? "")"
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.errorFeedbackButton, .click, routeValue))
        if let url = URL(string: "https://docs.google.com/forms/d/1GR4t8IfTOrYY4jxq5YAS7YiCS8QIFtHaWu_kE-SdDKY"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func configureSwipeGestures() {
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeftGesture.direction = .left
        oneBusTimetableDataTableView.addGestureRecognizer(swipeLeftGesture)
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRightGesture.direction = .right
        oneBusTimetableDataTableView.addGestureRecognizer(swipeRightGesture)
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let currentSegmentIndex = segmentControl.selectedSegmentIndex
        if gesture.direction == .left {
            if currentSegmentIndex < segmentControl.numberOfSegments - 1 {
                segmentControl.selectedSegmentIndex = currentSegmentIndex + 1
            }
        } else if gesture.direction == .right {
            if currentSegmentIndex > 0 {
                segmentControl.selectedSegmentIndex = currentSegmentIndex - 1
            }
        }
        changeSegmentControl(sender: segmentControl)
    }
    
    private func moveUnderLineView() {
        let newXPosition = (segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)) * CGFloat(segmentControl.selectedSegmentIndex)
        selectedUnderlineView.snp.updateConstraints {
            $0.leading.equalTo(segmentControl).offset(newXPosition)
        }
        UIView.animate (
            withDuration: 0.4,
            animations: { [weak self] in
                guard let self = self
                else { return }
                self.view.layoutIfNeeded()
            }
        )
    }
    
    private func updateShuttleBusTimetable(timetable: ShuttleBusTimetable, shuttleTimetableType: ShuttleTimetableType) {
        shuttleRouteTypeLabel.text = timetable.routeType.rawValue
        shuttleRouteTypeLabel.backgroundColor = UIColor.setColor(timetable.routeType.returnRouteColor())
        busTimetablePlaceLabel.text = timetable.routeName
        subBusTimetablePlaceLabel.text = timetable.subName
        if timetable.routeType == .weekday && timetable.routeInfo.count > 1 {
            manyBusTimetableDataCollectionView.configure(busInfo: timetable.routeInfo)
            [segmentControl, shadowView, selectedUnderlineView, oneBusTimetableDataTableView].forEach {
                $0.isHidden = false
            }
            [manyBusTimetableDataTableView, manyBusTimetableDataCollectionView, busTimetableSeparateView, headerColorView, scrollView].forEach {
                $0.isHidden = true
            }
            if shuttleTimetableType == .dropOffSchool {
                oneBusTimetableDataTableView.configure(nodeInfo: timetable.nodeInfo.reversed(), routeInfo: timetable.routeInfo[1].arrivalTime)
            }
            else {
                oneBusTimetableDataTableView.configure(nodeInfo: timetable.nodeInfo, routeInfo: timetable.routeInfo.first?.arrivalTime ?? [])
            }
        }
        else {
            [segmentControl, shadowView, selectedUnderlineView, oneBusTimetableDataTableView].forEach {
                $0.isHidden = true
            }
            [manyBusTimetableDataTableView, manyBusTimetableDataCollectionView, busTimetableSeparateView, headerColorView, scrollView].forEach {
                $0.isHidden = false
            }
            manyBusTimetableDataTableView.configure(timetable: timetable.nodeInfo)
            manyBusTimetableDataCollectionView.configure(busInfo: timetable.routeInfo)
        }
    }
}

extension BusTimetableDataViewController {
    private func setUpLayouts() {
        [shuttleRouteTypeLabel, busTimetablePlaceLabel, scrollView, segmentControl, shadowView, selectedUnderlineView, oneBusTimetableDataTableView, subBusTimetablePlaceLabel].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(contentView)
        [busTimetableBorderView, manyBusTimetableDataTableView, manyBusTimetableDataCollectionView, busTimetableSeparateView, headerColorView, incorrectBusInfoButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(subBusTimetablePlaceLabel.snp.bottom).offset(16)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1500)
        }
        shuttleRouteTypeLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(28)
            $0.height.equalTo(18)
        }
        busTimetablePlaceLabel.snp.makeConstraints {
            $0.leading.equalTo(shuttleRouteTypeLabel)
            $0.top.equalTo(shuttleRouteTypeLabel.snp.bottom).offset(4)
            $0.height.equalTo(32)
        }
        subBusTimetablePlaceLabel.snp.makeConstraints {
            $0.leading.equalTo(shuttleRouteTypeLabel)
            $0.top.equalTo(busTimetablePlaceLabel.snp.bottom).offset(4)
            $0.height.equalTo(19)
        }
        oneBusTimetableDataTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(selectedUnderlineView.snp.bottom)
            $0.bottom.equalToSuperview()
        }
        busTimetableBorderView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(1)
        }
        manyBusTimetableDataTableView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview()
            $0.width.equalTo(152)
            $0.top.equalTo(busTimetableBorderView.snp.bottom)
        }
        manyBusTimetableDataCollectionView.snp.makeConstraints {
            $0.leading.equalTo(manyBusTimetableDataTableView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(busTimetableBorderView.snp.bottom).offset(1)
            $0.bottom.equalToSuperview()
        }
        busTimetableSeparateView.snp.makeConstraints {
            $0.leading.equalTo(manyBusTimetableDataTableView.snp.trailing)
            $0.width.equalTo(0.5)
            $0.top.equalTo(manyBusTimetableDataTableView)
            $0.height.equalTo(300)
        }
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(subBusTimetablePlaceLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        shadowView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview()
            $0.top.equalTo(segmentControl.snp.bottom)
            $0.height.equalTo(1)
        }
        selectedUnderlineView.snp.makeConstraints {
            $0.leading.equalTo(segmentControl.snp.leading)
            $0.height.equalTo(2)
            $0.top.equalTo(segmentControl.snp.bottom)
            $0.width.equalTo(segmentControl.snp.width).dividedBy(segmentControl.numberOfSegments)
        }
        headerColorView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.width.equalTo(0)
            $0.top.equalTo(self.manyBusTimetableDataCollectionView)
            $0.height.equalTo(52)
        }
        incorrectBusInfoButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.height.equalTo(20)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
        view.backgroundColor = .systemBackground
        configureSwipeGestures()
    }
}

