//
//  AddDirectHeaderView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class AddDirectHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    static let identifier = "AddDirectHeaderView"
    let nameChangedPublisher = PassthroughSubject<String, Never>()
    let professorChangedPublisher = PassthroughSubject<String, Never>()
    let rowChangedPublisher = PassthroughSubject<AddDirectCollectionView.Row, Never>()
    private var row = AddDirectCollectionView.Row()
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - UI Components
    let calendarView = ClassComponentView(text: "일정명", isPoint: true).then { _ in
    }
    
    private let professorNameView = ClassComponentView(text: "교수명", isPoint: false).then { _ in
    }
    
    let selectTimeView = SelectTimeView(frame: .zero, size: .big).then { _ in
    }
    
    let placeView = ClassComponentView(text: "장소", isPoint: false).then { _ in
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        bind()
    }
    
    func configure(name: String, professor: String, row: AddDirectCollectionView.Row) {
        self.row = row
        calendarView.setText(name)
        professorNameView.setText(professor)
        selectTimeView.configure(row: row)
        placeView.setText(row.place)
    }

    private func bind() {
        calendarView.textChangedPublisher.sink { [weak self] in
            self?.nameChangedPublisher.send($0)
        }.store(in: &subscriptions)
        professorNameView.textChangedPublisher.sink { [weak self] in
            self?.professorChangedPublisher.send($0)
        }.store(in: &subscriptions)
        placeView.textChangedPublisher.sink { [weak self] value in
            guard let self else { return }
            self.row.place = value
            self.rowChangedPublisher.send(self.row)
        }.store(in: &subscriptions)
        selectTimeView.selectionChangedPublisher.sink { [weak self] in
            guard let self else { return }
            self.row.day = self.selectTimeView.dayIndex
            self.row.startMinute = self.selectTimeView.startMinute
            self.row.endMinute = self.selectTimeView.endMinute
            self.rowChangedPublisher.send(self.row)
        }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddDirectHeaderView {
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
    }

    private func setUpLayouts() {
        [calendarView, professorNameView, selectTimeView, placeView].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        calendarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(35)
        }
        professorNameView.snp.makeConstraints {
            $0.top.equalTo(calendarView.snp.bottom).offset(8)
            $0.leading.trailing.height.equalTo(calendarView)
        }
        selectTimeView.snp.makeConstraints {
            $0.top.equalTo(professorNameView.snp.bottom).offset(8)
            $0.leading.trailing.height.equalTo(calendarView)
        }
        placeView.snp.makeConstraints {
            $0.top.equalTo(selectTimeView.snp.bottom).offset(8)
            $0.leading.trailing.height.equalTo(calendarView)
            $0.bottom.equalToSuperview()
        }
    }
}
