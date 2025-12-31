//
//  AddClassCollectionView.swift
//  koin
//
//  Created by 김나훈 on 11/19/24.
//

import Combine
import UIKit

final class AddClassCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var lectureList: [SemesterLecture] = []
    private var showingLectureList: [SemesterLecture] = []
    private var myLectureList: [LectureData] = []
    private var selectedLecture: SemesterLecture?
    
    let completeButtonPublisher = PassthroughSubject<Void, Never>()
    let addDirectButtonPublisher = PassthroughSubject<Void, Never>()
    let modifyClassButtonPublisher = PassthroughSubject<(LectureData, Bool), Never>()
    let didTapCellPublisher = PassthroughSubject<(SemesterLecture?, [SemesterLecture]), Never>()
    let filterButtonPublisher = PassthroughSubject<Void, Never>()
    private var headerCancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionHeadersPinToVisibleBounds = true
        super.init(frame: frame, collectionViewLayout: flowLayout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        isScrollEnabled = true
        register(AddClassCollectionViewCell.self, forCellWithReuseIdentifier: AddClassCollectionViewCell.identifier)
        register(AddClassHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AddClassHeaderView.identifier)
        dataSource = self
        delegate = self
    }
    
    func setUpLectureList(lectureList: [SemesterLecture]) {
        self.lectureList = lectureList
        self.showingLectureList = lectureList
        reloadData()
    }
    
    func setUpMyLecture(myLectureList: [LectureData]) {
        self.myLectureList = myLectureList
        reloadData()
    }
    func setUpSelectedDept(dept: String?) {
        if let dept {
            showingLectureList = lectureList.filter { $0.department == dept }
        } else {
            showingLectureList = lectureList
        }
        reloadData()
    }
    
}

extension AddClassCollectionView {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 84)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24) // 섹션의 좌우 간격
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showingLectureList.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 103)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedLecture = showingLectureList[indexPath.row]

        if selectedLecture == self.selectedLecture {
            didTapCellPublisher.send((nil, [])) // View를 모두 제거
            self.selectedLecture = nil // 선택 해제
            return
        }
    
        self.selectedLecture = selectedLecture

        let filteredLectures = lectureList.filter { lecture in
            lecture.name == selectedLecture.name &&
            lecture != selectedLecture &&
            !lecture.classTime.contains(where: selectedLecture.classTime.contains)
        }
        didTapCellPublisher.send((selectedLecture, filteredLectures))
    }

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddClassHeaderView.identifier, for: indexPath) as? AddClassHeaderView else {
                return UICollectionReusableView()
            }
            headerCancellables.removeAll()
            headerView.completeButtonPublisher.sink { [weak self] in
                self?.completeButtonPublisher.send()
            }.store(in: &headerCancellables)
            headerView.addDirectButtonPublisher.sink { [weak self] in
                self?.addDirectButtonPublisher.send()
            }.store(in: &headerCancellables)
            headerView.filterButtonPublisher.sink { [weak self] in
                self?.filterButtonPublisher.send()
            }.store(in: &headerCancellables)
            headerView.searchClassPublisher.sink { [weak self] text in
                guard let self = self else { return }
                if text.isEmpty {
                    showingLectureList = lectureList
                } else {
                    self.showingLectureList = self.lectureList.filter { $0.name.contains(text) }
                }
                reloadData()
            }.store(in: &headerCancellables)
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddClassCollectionViewCell.identifier, for: indexPath) as? AddClassCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let lecture = showingLectureList[indexPath.row]
        
        // `isAdded` 계산
        let isAdded = myLectureList.contains { myLecture in
            myLecture.name == lecture.name &&
            myLecture.classTime == lecture.classTime &&
            myLecture.professor == (lecture.professor ?? "")
        }
        
        cell.configure(lecture: lecture, isAdded: isAdded)
        
        // 셀의 버튼 액션 처리
        cell.modifyClassButtonPublisher.sink { [weak self] _ in
            guard let self = self else { return }
            let item = showingLectureList[indexPath.row]
            self.modifyClassButtonPublisher.send((
                LectureData(
                    id: item.id,
                    name: item.name,
                    professor: item.professor ?? "",
                    classTime: item.classTime,
                    grades: item.grades
                ),
                !isAdded
            ))
        }.store(in: &cell.cancellables)
        return cell
    }
    
    
}
