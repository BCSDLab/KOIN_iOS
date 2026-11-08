//
//  AddClassCollectionView.swift
//  koin
//
//  Created by 김나훈 on 11/19/24.
//

import Combine
import UIKit

final class AddClassCollectionView: UIView, TimetableScrollableSheet, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    private var lectureList: [SemesterLecture] = []
    private var showingLectureList: [SemesterLecture] = []
    private var myLectureList: [LectureData] = []
    private var selectedLecture: SemesterLecture?
    
    let completeButtonPublisher = PassthroughSubject<Void, Never>()
    let addDirectButtonPublisher = PassthroughSubject<Void, Never>()
    let modifyClassButtonPublisher = PassthroughSubject<(LectureData, Bool), Never>()
    let didTapCellPublisher = PassthroughSubject<(SemesterLecture?, [SemesterLecture]), Never>()
    let filterButtonPublisher = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()
    var sheetScrollView: UIScrollView { collectionView }
    /// 수업 추가 시트의 고정 높이. 직접 추가 시트의 최대 높이로도 쓴다.
    static let sheetHeight: CGFloat = 416

    // MARK: - UI Components
    private let headerView = AddClassHeaderView()
    private let buttonBar = TimetableSheetButtonBar(secondaryTitle: "직접 추가")
    private let collectionView: UICollectionView

    func calculateSheetHeight(in context: KoinBottomSheetContext) -> CGFloat {
        min(Self.sheetHeight, context.maximumHeight)
    }

    init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        configureView()
        bind()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func bind() {
        headerView.closePublisher.sink { [weak self] in self?.completeButtonPublisher.send() }.store(in: &subscriptions)
        headerView.filterButtonPublisher.sink { [weak self] in self?.filterButtonPublisher.send() }.store(in: &subscriptions)
        buttonBar.secondaryPublisher.sink { [weak self] in self?.addDirectButtonPublisher.send() }.store(in: &subscriptions)
        buttonBar.primaryPublisher.sink { [weak self] in self?.completeButtonPublisher.send() }.store(in: &subscriptions)
        headerView.searchClassPublisher.sink { [weak self] text in
            guard let self else { return }
            self.showingLectureList = text.isEmpty ? self.lectureList : self.lectureList.filter { $0.name.contains(text) }
            self.collectionView.reloadData()
        }.store(in: &subscriptions)
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .appColor(.neutral0)
        collectionView.backgroundColor = .appColor(.neutral0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
    }

    private func setUpLayouts() {
        collectionView.register(AddClassCollectionViewCell.self, forCellWithReuseIdentifier: AddClassCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        [headerView, collectionView, buttonBar].forEach { addSubview($0) }
    }

    private func setUpConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(126)
        }
        buttonBar.snp.makeConstraints { $0.leading.trailing.bottom.equalToSuperview() }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(buttonBar.snp.top)
        }
    }

    func setUpLectureList(lectureList: [SemesterLecture]) {
        self.lectureList = lectureList
        self.showingLectureList = lectureList
        collectionView.reloadData()
    }
    
    func setUpMyLecture(myLectureList: [LectureData]) {
        self.myLectureList = myLectureList
        collectionView.reloadData()
    }
    func setUpSelectedDept(dept: String?) {
        if let dept {
            showingLectureList = lectureList.filter { $0.department == dept }
        } else {
            showingLectureList = lectureList
        }
        collectionView.reloadData()
    }
    
}

extension AddClassCollectionView {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 64, height: 76)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 32, bottom: 4, right: 32) // 섹션의 좌우 간격
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showingLectureList.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedLecture = showingLectureList[indexPath.row]

        if selectedLecture == self.selectedLecture {
            didTapCellPublisher.send((nil, [])) // View를 모두 제거
            self.selectedLecture = nil // 선택 해제
            collectionView.reloadData()
            return
        }
    
        self.selectedLecture = selectedLecture

        let filteredLectures = lectureList.filter { lecture in
            lecture.name == selectedLecture.name &&
            lecture != selectedLecture &&
            !lecture.classTime.contains(where: selectedLecture.classTime.contains)
        }
        didTapCellPublisher.send((selectedLecture, filteredLectures))
        collectionView.reloadData()
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddClassCollectionViewCell.identifier, for: indexPath) as? AddClassCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let lecture = showingLectureList[indexPath.row]
        
        // `isAdded` 계산
        let isAdded = myLectureList.contains { myLecture in
            myLecture.name == lecture.name &&
            Set(myLecture.classTime) == Set(lecture.classTime) &&
            myLecture.professor == (lecture.professor ?? "")
        }
        
        cell.cancellables.removeAll()
        cell.configure(lecture: lecture, isAdded: isAdded, isPreviewing: lecture == selectedLecture && !isAdded)
        
        // 셀의 버튼 액션 처리
        cell.modifyClassButtonPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            let item = lecture
            self.modifyClassButtonPublisher.send((
                LectureData(
                    id: item.id,
                    name: item.name,
                    professor: item.professor ?? "",
                    classTime: item.classTime,
                    grades: item.grades,
                    lectureId: item.id,
                    code: item.code,
                    lectureClass: item.lectureClass
                ),
                !isAdded
            ))
        }.store(in: &cell.cancellables)
        return cell
    }
    
    
}
