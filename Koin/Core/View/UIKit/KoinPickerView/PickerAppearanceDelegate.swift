//
//  PickerAppearanceDelegate.swift
//  koin
//
//  Created by 홍기정 on 10/30/26.
//

import UIKit

/// Style 적용 + UIPickerView ↔ PickerColumnsDataSource 연결. 선택 이벤트는 onSelectRow로 위임
final class PickerAppearanceDelegate: NSObject {

    // MARK: - Properties
    private let style: KoinPickerView.Style
    private let columnSpacing: KoinPickerView.ColumnSpacing
    /// 컴포넌트별 정렬. 없으면 가운데
    private let columnAlignments: [Int: NSTextAlignment]
    private let columnsDataSource: PickerColumnsDataSource
    /// 후보 문자열의 숫자를 가장 넓은 숫자로 치환해 측정한 최대 폭 + 여유 1
    private lazy var columnWidths: [CGFloat] = (0..<columnsDataSource.numberOfComponents).map { component in
        let widths = columnsDataSource.widthTemplates(inComponent: component).map {
            textWidth(String($0.map { $0.isASCII && $0.isNumber ? widestDigit : $0 }))
        }
        return ceil(widths.max() ?? 0) + 1
    }
    /// style.font에서 가장 넓은 숫자. 숫자 폭이 글꼴마다 제각각이라 1회 측정
    private lazy var widestDigit: Character = "0123456789"
        .map { (digit: $0, width: textWidth(String($0))) }
        .max { $0.width < $1.width }?.digit ?? "0"
    private lazy var columnInsets = columnSpacing.insets(numberOfColumns: columnsDataSource.numberOfComponents)

    var onSelectRow: ((_ row: Int, _ component: Int) -> Void)?

    // MARK: - Initializer
    init(
        style: KoinPickerView.Style,
        columnSpacing: KoinPickerView.ColumnSpacing,
        columnAlignments: [Int: NSTextAlignment],
        columnsDataSource: PickerColumnsDataSource
    ) {
        self.style = style
        self.columnSpacing = columnSpacing
        self.columnAlignments = columnAlignments
        self.columnsDataSource = columnsDataSource
        super.init()
    }

    private func textWidth(_ text: String) -> CGFloat {
        return (text as NSString).size(withAttributes: [.font: style.font]).width
    }
}

extension PickerAppearanceDelegate: UIPickerViewDataSource {

    func numberOfComponents(
        in pickerView: UIPickerView
    ) -> Int {
        return columnsDataSource.numberOfComponents
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        return columnsDataSource.numberOfRows(inComponent: component)
    }
}

extension PickerAppearanceDelegate: UIPickerViewDelegate {

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        onSelectRow?(row, component)
    }

    func pickerView(
        _ pickerView: UIPickerView,
        rowHeightForComponent component: Int
    ) -> CGFloat {
        return KoinPickerView.rowHeight
    }

    /// 왼쪽 여백 + 글자 폭 + 오른쪽 여백
    func pickerView(
        _ pickerView: UIPickerView,
        widthForComponent component: Int
    ) -> CGFloat {
        let insets = columnInsets.indices.contains(component) ? columnInsets[component] : .zero
        return insets.left + (columnWidths.indices.contains(component) ? columnWidths[component] : 0) + insets.right
    }

    func pickerView(
        _ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?
    ) -> UIView {
        let isSelected = columnsDataSource.selectedRow(inComponent: component) == row
        let rowView = (view as? PickerRowView) ?? PickerRowView()
        rowView.horizontalInsets = columnInsets.indices.contains(component) ? columnInsets[component] : .zero
        rowView.label.do {
            $0.textAlignment = columnAlignments[component] ?? .center
            $0.font = style.font
            $0.text = columnsDataSource.title(forRow: row, inComponent: component)
            $0.backgroundColor = .clear
            $0.textColor = isSelected ? style.selectedColor : style.deselectedColor
        }
        return rowView
    }
}

// MARK: - PickerRowView
/// 컴포넌트 폭 안에서 좌우 여백을 뺀 글자 폭 영역에 label 배치. 정렬은 글자 폭 기준
private final class PickerRowView: UIView {

    let label = UILabel()
    var horizontalInsets: UIEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(label)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds.inset(by: horizontalInsets)
    }
}
