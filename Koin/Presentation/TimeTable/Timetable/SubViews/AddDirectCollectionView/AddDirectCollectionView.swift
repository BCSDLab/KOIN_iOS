//
//  AddDirectCollectionView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class AddDirectCollectionView: UIView, TimetableScrollableSheet, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    /// 시간·장소 한 줄. 헤더가 0번, 셀이 1번부터를 맡는다.
    struct Row {
        var day = 0
        var startMinute = 540
        var endMinute = 600
        var place = ""

        var isValid: Bool {
            (0..<5).contains(day) && startMinute >= 540 && endMinute <= 1440 && endMinute > startMinute
        }

        /// 09:00부터 30분 단위 시간 코드. 유효하지 않은 줄은 빈 배열.
        var classTime: [Int] {
            guard isValid else { return [] }
            return stride(from: startMinute, to: endMinute, by: 30).map { day * 100 + ($0 - 540) / 30 }
        }
    }

    // MARK: - Properties
    let completeButtonPublisher = PassthroughSubject<TimetableLecture, Never>()
    let addClassButtonPublisher = PassthroughSubject<Void, Never>()
    /// 줄 하나가 classInfos 하나다. 유효하지 않은 줄도 빈 classTime으로 남는다.
    let requestChangedPublisher = PassthroughSubject<TimetableLecture, Never>()
    let weekdayDropdownPublisher = PassthroughSubject<(anchor: UIView, content: UIView & KoinDropdownContentView), Never>()
    let closeButtonPublisher = PassthroughSubject<Void, Never>()
    private var editingLecture: LectureData?
    private var name = ""
    private var professor = ""
    private var rows = [Row()]
    var isEditing: Bool { editingLecture != nil }
    private var headerCancellables = Set<AnyCancellable>()
    private var footerCancellables = Set<AnyCancellable>()
    private var subscriptions = Set<AnyCancellable>()
    var sheetScrollView: UIScrollView { collectionView }

    // MARK: - UI Components
    private let titleView = TimetableSheetTitleView(title: "수업 추가")
    private let buttonBar = TimetableSheetButtonBar(secondaryTitle: "돌아가기")
    private let collectionView: UICollectionView
    func calculateSheetHeight(in context: KoinBottomSheetContext) -> CGFloat {
        let contentHeight = 345 + CGFloat(max(0, rows.count - 1)) * 134
        return min(contentHeight, AddClassCollectionView.sheetHeight, context.maximumHeight)
    }

    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        configureView()
        titleView.closePublisher.sink { [weak self] in self?.closeButtonPublisher.send() }.store(in: &subscriptions)
        buttonBar.secondaryPublisher.sink { [weak self] in self?.addClassButtonPublisher.send() }.store(in: &subscriptions)
        buttonBar.primaryPublisher.sink { [weak self] in self?.completeButtonTapped() }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func beginAdding() {
        resetForm()
    }

    func beginEditing(_ lecture: LectureData) {
        endEditing(true)
        editingLecture = lecture
        name = lecture.name
        professor = lecture.professor
        rows = Self.rows(from: lecture)
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
        publishChanges()
    }

    func resetForm() {
        endEditing(true)
        editingLecture = nil
        name = ""
        professor = ""
        rows = [Row()]
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
        publishChanges()
    }

    /// 지금 폼 값으로 만든 요청. 수정이면 기존 학점·메모를 유지한다.
    var request: TimetableLecture {
        TimetableLecture(
            lectureID: nil,
            classTitle: name.trimmingCharacters(in: .whitespacesAndNewlines),
            classInfos: rows.map {
                ClassInfo(classTime: $0.classTime, classPlace: $0.place.trimmingCharacters(in: .whitespacesAndNewlines))
            },
            professor: professor.trimmingCharacters(in: .whitespacesAndNewlines),
            grades: editingLecture?.grades ?? "0",
            memo: editingLecture?.memo ?? "no memo",
            id: editingLecture?.id
        )
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !rows.isEmpty && rows.allSatisfy(\.isValid)
    }

    private func publishChanges() {
        titleView.setTitle(isEditing ? "수업 수정" : "수업 추가")
        buttonBar.setTitles(secondary: isEditing ? "취소" : "돌아가기", primary: isEditing ? "수정하기" : "완료")
        buttonBar.setPrimaryEnabled(isValid)
        requestChangedPublisher.send(request)
    }

    private func updateRow(_ row: Row, at index: Int) {
        guard rows.indices.contains(index) else { return }
        rows[index] = row
        publishChanges()
    }

    private func addRow() {
        rows.append(Row())
        let indexPath = IndexPath(item: rows.count - 2, section: 0)
        collectionView.insertItems(at: [indexPath])
        publishChanges()
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }

    private func removeRow(at index: Int) {
        guard rows.indices.contains(index), index > 0 else { return }
        endEditing(true)
        rows.remove(at: index)
        collectionView.deleteItems(at: [IndexPath(item: index - 1, section: 0)])
        publishChanges()
    }

    private func completeButtonTapped() {
        guard isValid else { return }
        completeButtonPublisher.send(request)
    }

    /// 수정할 강의의 시간 코드를 요일별 연속 구간으로 나눠 줄을 만든다.
    private static func rows(from lecture: LectureData) -> [Row] {
        let infos = lecture.classInfos ?? [LectureClassInfo(classTime: lecture.classTime, classPlace: "")]
        let rows = infos.flatMap { info -> [Row] in
            let byDay = Dictionary(grouping: Set(info.classTime)) { $0 / 100 }
            return byDay.keys.sorted().flatMap { day -> [Row] in
                let slots = (byDay[day] ?? []).map { $0 % 100 }.sorted()
                var result: [Row] = []
                var first: Int?
                var last: Int?
                for slot in slots {
                    if let previous = last, slot != previous + 1, let start = first {
                        result.append(Row(day: day, startMinute: 540 + start * 30, endMinute: 540 + (previous + 1) * 30, place: info.classPlace))
                        first = slot
                    } else if first == nil {
                        first = slot
                    }
                    last = slot
                }
                if let start = first, let end = last {
                    result.append(Row(day: day, startMinute: 540 + start * 30, endMinute: 540 + (end + 1) * 30, place: info.classPlace))
                }
                return result
            }
        }
        return rows.isEmpty ? [Row()] : rows
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        buttonBar.setPrimaryEnabled(false)
        collectionView.backgroundColor = .appColor(.neutral0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
    }

    private func setUpLayouts() {
        collectionView.register(AddDirectCollectionViewCell.self, forCellWithReuseIdentifier: AddDirectCollectionViewCell.identifier)
        collectionView.register(AddDirectHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AddDirectHeaderView.identifier)
        collectionView.register(AddDirectFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AddDirectFooterView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        [titleView, collectionView, buttonBar].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        titleView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(66)
        }
        buttonBar.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview() }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonBar.snp.top)
        }
    }
}

extension AddDirectCollectionView {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 32, bottom: rows.count > 1 ? 8 : 0, right: 32)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width - 64, height: 126)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        max(0, rows.count - 1)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { 8 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 0 }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 164)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 35)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddDirectHeaderView.identifier, for: indexPath) as? AddDirectHeaderView else { return UICollectionReusableView() }
            headerCancellables.removeAll()
            header.configure(name: name, professor: professor, row: rows.first ?? Row())
            header.nameChangedPublisher.sink { [weak self] value in
                self?.name = value
                self?.publishChanges()
            }.store(in: &headerCancellables)
            header.professorChangedPublisher.sink { [weak self] value in
                self?.professor = value
                self?.publishChanges()
            }.store(in: &headerCancellables)
            header.rowChangedPublisher.sink { [weak self] in self?.updateRow($0, at: 0) }.store(in: &headerCancellables)
            header.selectTimeView.weekdayDropdownPublisher.sink { [weak self] in self?.weekdayDropdownPublisher.send($0) }.store(in: &headerCancellables)
            return header
        }
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddDirectFooterView.identifier, for: indexPath) as? AddDirectFooterView else { return UICollectionReusableView() }
            footerCancellables.removeAll()
            footer.footerTapPublisher.sink { [weak self] in self?.addRow() }.store(in: &footerCancellables)
            return footer
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddDirectCollectionViewCell.identifier, for: indexPath) as? AddDirectCollectionViewCell else { return UICollectionViewCell() }
        cell.cancellables.removeAll()
        cell.configure(row: rows[indexPath.item + 1])
        // 줄이 삭제되면 셀 위치가 바뀌므로, 이벤트가 올 때 현재 위치를 다시 찾는다. 헤더가 0번 줄이다.
        cell.rowChangedPublisher.sink { [weak self, weak cell] row in
            guard let self, let cell, let indexPath = self.collectionView.indexPath(for: cell) else { return }
            self.updateRow(row, at: indexPath.item + 1)
        }.store(in: &cell.cancellables)
        cell.deleteButtonPublisher.sink { [weak self, weak cell] in
            guard let self, let cell, let indexPath = self.collectionView.indexPath(for: cell) else { return }
            self.removeRow(at: indexPath.item + 1)
        }.store(in: &cell.cancellables)
        cell.selectTimeView.weekdayDropdownPublisher.sink { [weak self] in self?.weekdayDropdownPublisher.send($0) }.store(in: &cell.cancellables)
        return cell
    }
}
