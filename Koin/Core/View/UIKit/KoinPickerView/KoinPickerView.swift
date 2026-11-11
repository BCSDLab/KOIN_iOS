//
//  KoinPickerView.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import UIKit
import Combine
import SnapKit

final class KoinPickerView: UIView {

    // MARK: - Publisher
    /// 사용자가 휠을 조작했을 때만 발행
    var datePublisher: AnyPublisher<Date, Never> {
        return dateSubject.eraseToAnyPublisher()
    }
    private let dateSubject = PassthroughSubject<Date, Never>()

    // MARK: - Properties
    /// 행 내용 26 + 행 간격 6
    static let rowHeight: CGFloat = 32
    private static let rowContentHeight: CGFloat = 26
    private static let rowSpacing: CGFloat = 6

    var date: Date {
        return columnsDataSource.date
    }

    /// UIPickerView의 dataSource·delegate는 weak 참조라 여기서 strong 보관
    private let columnsDataSource: PickerColumnsDataSource
    private let appearanceDelegate: PickerAppearanceDelegate
    private let visibleRowCount: VisibleRowCount

    /// 높이 = 26n + 6(n-1)
    override var intrinsicContentSize: CGSize {
        let count = CGFloat(visibleRowCount.rawValue)
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: KoinPickerView.rowContentHeight * count + KoinPickerView.rowSpacing * (count - 1)
        )
    }

    // MARK: - UI Components
    private let pickerView = UIPickerView(frame: .zero)

    // MARK: - Initializer
    init(configuration: Configuration) {
        let columnsDataSource = KoinPickerView.makeColumnsDataSource(configuration: configuration, initialDate: Date())
        self.columnsDataSource = columnsDataSource
        self.appearanceDelegate = PickerAppearanceDelegate(
            style: configuration.style,
            columnSpacing: configuration.columnSpacing,
            columnAlignments: KoinPickerView.makeColumnAlignments(configuration: configuration),
            columnsDataSource: columnsDataSource
        )
        self.visibleRowCount = configuration.visibleRowCount

        super.init(frame: .zero)

        appearanceDelegate.onSelectRow = { [weak self] row, component in
            self?.userDidSelectRow(row, inComponent: component)
        }
        pickerView.dataSource = appearanceDelegate
        pickerView.delegate = appearanceDelegate
        configureView()
        reloadAllComponents(animated: false)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// UIPickerView는 window 밖·크기 0일 때 selectRow가 휠에 반영되지 않는다(드롭다운은 열기 전에 setDate)
    private var syncedPickerSize: CGSize = .zero

    override func didMoveToWindow() {
        super.didMoveToWindow()
        syncedPickerSize = .zero
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for subview in pickerView.subviews {
            subview.backgroundColor = .clear
        }

        guard window != nil, pickerView.bounds.size != syncedPickerSize else { return }
        syncedPickerSize = pickerView.bounds.size
        pickerView.layoutIfNeeded()
        selectRows(animated: false, force: true)
    }

    // MARK: - Public
    /// 이벤트 없음. 초·나노초 버림, 범위 clamp, 간격 보정
    func setDate(_ date: Date, animated: Bool) {
        columnsDataSource.setDate(date)
        reloadAllComponents(animated: animated)
    }

    /// 이벤트 없음. 현재 값 재정규화
    func setRange(minimum: Date?, maximum: Date?) {
        columnsDataSource.setRange(minimum: minimum, maximum: maximum)
        reloadAllComponents(animated: false)
    }

    /// 컬럼의 선택 행 frame(self 좌표). host가 picker 위에 뷰를 겹칠 때 사용. 화면에 없으면 nil
    func frame(ofColumn column: Int) -> CGRect? {
        guard 0 <= column, column < columnsDataSource.numberOfComponents else {
            return nil
        }
        layoutIfNeeded()
        let row = columnsDataSource.selectedRow(inComponent: column)
        guard let rowView = pickerView.view(forRow: row, forComponent: column) else {
            return nil
        }
        return rowView.convert(rowView.bounds, to: self)
    }
}

extension KoinPickerView {

    private func userDidSelectRow(_ row: Int, inComponent component: Int) {
        let changedComponents = columnsDataSource.selectRow(row, inComponent: component)
        changedComponents.forEach {
            pickerView.reloadComponent($0)
        }
        // 보정된 다른 컬럼은 애니메이션 없이 이동
        selectRows(animated: false)
        dateSubject.send(columnsDataSource.date)
    }

    private func reloadAllComponents(animated: Bool) {
        pickerView.reloadAllComponents()
        selectRows(animated: animated)
    }

    /// force: picker 내부 selectedRow와 휠 위치가 어긋났을 수 있을 때 비교 없이 다시 선택
    private func selectRows(animated: Bool, force: Bool = false) {
        for component in 0..<columnsDataSource.numberOfComponents {
            let row = columnsDataSource.selectedRow(inComponent: component)
            if force || pickerView.selectedRow(inComponent: component) != row {
                pickerView.selectRow(row, inComponent: component, animated: animated)
            }
        }
    }

    /// dateAndTime 컬럼 순서: 날짜 · 오전/오후 · 시 · 분
    private static func makeColumnAlignments(configuration: Configuration) -> [Int: NSTextAlignment] {
        switch configuration.mode {
        case .dateAndTime: return [0: configuration.format.dateColumnAlignment]
        case .date, .time12h, .time24h: return [:]
        }
    }

    private static func makeColumnsDataSource(
        configuration: Configuration,
        initialDate: Date
    ) -> PickerColumnsDataSource {
        let minuteInterval = configuration.minuteInterval.rawValue
        switch configuration.mode {
        case .date:
            return DateColumns(
                minimumDate: configuration.minimumDate,
                maximumDate: configuration.maximumDate,
                initialDate: initialDate
            )
        case .time12h:
            return Time12Columns(
                minimumDate: configuration.minimumDate,
                maximumDate: configuration.maximumDate,
                minuteInterval: minuteInterval,
                meridiemSymbols: configuration.format.meridiemSymbols,
                initialDate: initialDate
            )
        case .time24h:
            return Time24Columns(
                minimumDate: configuration.minimumDate,
                maximumDate: configuration.maximumDate,
                minuteInterval: minuteInterval,
                initialDate: initialDate
            )
        case .dateAndTime:
            return DateAndTimeColumns(
                minimumDate: configuration.minimumDate,
                maximumDate: configuration.maximumDate,
                minuteInterval: minuteInterval,
                relativeDayReference: configuration.format.relativeDayReference,
                meridiemSymbols: configuration.format.meridiemSymbols,
                initialDate: initialDate
            )
        }
    }

    private func configureView() {
        // 높이는 intrinsicContentSize를 따른다(UIPickerView 기본 높이 무시)
        pickerView.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        [pickerView].forEach {
            addSubview($0)
        }
        pickerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
