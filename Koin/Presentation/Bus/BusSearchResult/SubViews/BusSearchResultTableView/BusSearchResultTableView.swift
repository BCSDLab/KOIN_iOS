//
//  BusSearchResultTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import SnapKit
import Then
import UIKit

final class BusSearchResultTableView: UITableView {
    // MARK: - Properties
    let tapDepartTimeButtonPublisher = PassthroughSubject<Void, Never>()
    let tapDepartBusTypeButtonPublisher = PassthroughSubject<BusType, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var busSearchResult: SearchBusInfoResult = .init(depart: .koreatech, arrival: .terminal, departDate: Date(), departTime: Date(), schedule: [])
    private var busSearchSchedule: [ScheduleInformation] = []
    /// 헤더 재생성·재사용 시 다시 넣을 표시 상태
    private var departTimeText: String?
    private var departBusType: BusType = .noValue
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(BusSearchResultTableViewCell.self, forCellReuseIdentifier: BusSearchResultTableViewCell.identifier)
        register(BusSearchResultTableViewHeader.self, forHeaderFooterViewReuseIdentifier: BusSearchResultTableViewHeader.identifier)
        register(BusSearchResultTableViewFooter.self, forHeaderFooterViewReuseIdentifier: BusSearchResultTableViewFooter.reuseIdentifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
        backgroundColor = .systemBackground
        sectionHeaderTopPadding = 0
        let emptyContainer = UIView()
        let emptyView = BusSearchResultEmptyView()
        emptyContainer.addSubview(emptyView)
        emptyView.snp.makeConstraints { $0.center.equalToSuperview() }
        emptyContainer.isHidden = true
        backgroundView = emptyContainer
    }
    
    func setBusSearchTime(departTime: String) {
        departTimeText = departTime
        guard let view = self.headerView(forSection: 0) as? BusSearchResultTableViewHeader else { return }
        view.configureDepartTime(departTime: departTime)
    }
    
    func setBusSearchResult(busSearchResult: SearchBusInfoResult) {
        self.busSearchResult = busSearchResult
        self.busSearchSchedule = busSearchResult.schedule
        reloadData()
        backgroundView?.isHidden = !busSearchSchedule.isEmpty
        if busSearchResult.schedule.count > 0 {
            scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func clearBusSearchResult() {
        busSearchSchedule = []
        reloadData()
        backgroundView?.isHidden = true
    }
    
    private func showDropDown() {
        guard let header = headerView(forSection: 0) as? BusSearchResultTableViewHeader else { return }
        let content = BusTypeDropdownView { [weak self, weak header] busType in
            self?.departBusType = busType
            header?.configureDepartBusType(busType: busType)
            self?.tapDepartBusTypeButtonPublisher.send(busType)
        }
        presentDropdown(
            anchor: header.busTypeFilterButton,
            content: content,
            configuration: .init(direction: .down(spacing: 4), shadow: .shadow2)
        )
    }
}


extension BusSearchResultTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busSearchSchedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BusSearchResultTableViewCell.identifier, for: indexPath) as? BusSearchResultTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configure(searchModel: busSearchSchedule[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BusSearchResultTableViewHeader.identifier) as? BusSearchResultTableViewHeader else { return UIView() }
        if let departTimeText {
            view.configureDepartTime(departTime: departTimeText)
        }
        view.configureDepartBusType(busType: departBusType)
        // 같은 헤더가 다시 반환돼도 구독이 쌓이지 않도록 초기화
        view.subscriptions.removeAll()
        view.tapDepartTimeButtonPublisher.sink { [weak self] in
            self?.tapDepartTimeButtonPublisher.send()
        }.store(in: &view.subscriptions)
        view.tapDepartBusTypeButtonPublisher.sink { [weak self] in
            self?.showDropDown()
        }.store(in: &view.subscriptions)
        return view
    }
}

extension BusSearchResultTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 72
    }
}




/// 차종 필터 드롭다운 목록(전체 차종/셔틀버스/대성고속/시내버스)
private final class BusTypeDropdownView: UIView, KoinDropdownContentView {
    private static let busTypes: [BusType] = [.noValue, .shuttleBus, .expressBus, .cityBus]
    private static let rowHeight: CGFloat = 34
    private let dismissTappedSubject = PassthroughSubject<Void, Never>()
    var dismissTappedPublisher: AnyPublisher<Void, Never> { dismissTappedSubject.eraseToAnyPublisher() }
    let height: CGFloat = BusTypeDropdownView.rowHeight * CGFloat(BusTypeDropdownView.busTypes.count) + 12
    private let onSelect: (BusType) -> Void

    init(onSelect: @escaping (BusType) -> Void) {
        self.onSelect = onSelect
        super.init(frame: .zero)
        backgroundColor = .appColor(.neutral0)
        layer.cornerRadius = 16
        let stackView = UIStackView(arrangedSubviews: Self.busTypes.enumerated().map { makeButton(index: $0, busType: $1) })
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeButton(index: Int, busType: BusType) -> UIButton {
        var configuration = UIButton.Configuration.plain()
        configuration.attributedTitle = AttributedString(busType.koreanDescription, attributes: AttributeContainer([
            .font: UIFont.appFont(.pretendardRegular, size: 14),
            .foregroundColor: UIColor.appColor(.neutral800)
        ]))
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0)
        let button = UIButton(configuration: configuration)
        button.contentHorizontalAlignment = .leading
        button.configurationUpdateHandler = { button in
            button.configuration?.background.backgroundColor = .appColor(button.isHighlighted ? .neutral100 : .neutral0)
        }
        button.tag = index
        button.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
        button.snp.makeConstraints {
            $0.height.equalTo(Self.rowHeight)
        }
        return button
    }

    @objc private func tapButton(_ sender: UIButton) {
        onSelect(Self.busTypes[sender.tag])
        dismissTappedSubject.send()
    }
}

/// 검색 결과가 없을 때 표시 (CallVanNotificationEmptyView 형식)
private final class BusSearchResultEmptyView: UIView {
    init() {
        super.init(frame: .zero)
        let symbolImageView = UIImageView(image: .appImage(asset: .sleepBcsdSymbol))
        let titleLabel = UILabel().then {
            $0.text = "조건에 맞는 교통편이 없어요"
            $0.font = .appFont(.pretendardSemiBold, size: 18)
            $0.textColor = .appColor(.new500)
        }
        let subTitleLabel = UILabel().then {
            $0.text = "조건을 바꿔서 다시 확인해보세요"
            $0.font = .appFont(.pretendardMedium, size: 14)
            $0.textColor = .appColor(.neutral600)
        }
        [symbolImageView, titleLabel, subTitleLabel].forEach { addSubview($0) }
        symbolImageView.snp.makeConstraints {
            $0.width.equalTo(95)
            $0.height.equalTo(75)
            $0.top.centerX.equalToSuperview()
        }
        // 피그마 텍스트 높이 명시 (UIKit 라벨 기본 높이와 다름)
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(29)
            $0.top.equalTo(symbolImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints {
            $0.height.equalTo(22)
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
