//
//  TimetableViewController.swift
//  koin
//
//  Created by 김나훈 on 11/2/24.
//

import Combine
import UIKit

final class TimetableViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: TimetableViewModel
    private let inputSubject: PassthroughSubject<TimetableViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    
    // MARK: - UI Components
    
    private let emptyView = UIView()
    private let timetableColors: [(TimetableColorAsset, TimetableColorAsset)] = [
        (.body1, .header1),
        (.body2, .header2),
        (.body3, .header3),
        (.body4, .header4),
        (.body5, .header5),
        (.body6, .header6),
        (.body7, .header7),
        (.body8, .header8),
        (.body9, .header9),
        (.body10, .header10),
        (.body11, .header11),
        (.body12, .header12),
        (.body13, .header13),
        (.body14, .header14),
        (.body15, .header15)
    ]
    
    
    private let scrollView = UIScrollView().then { _ in
    }
    
    private let deleteLectureView = DeleteLectureView().then {
        $0.isHidden = true
    }
    
    private let semesterSelectButton = UIButton().then {
        $0.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        $0.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
    }
    
    private let downloadImageButton = UIButton().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage.appImage(asset: .downloadBold)
        var text = AttributedString("시간표 다운로드")
        text.font = UIFont.appFont(.pretendardRegular, size: 14)
        configuration.attributedTitle = text
        configuration.imagePadding = 8
        configuration.imagePlacement = .trailing
        configuration.baseBackgroundColor = .systemBackground
        configuration.baseForegroundColor = UIColor.appColor(.neutral800)
        $0.contentHorizontalAlignment = .leading
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8.5, bottom: 0, trailing: 0)
        $0.configuration = configuration
    }
    
    private let timetableCollectionView = TimetableCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        $0.layer.borderWidth = 1.0
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let addClassCollectionView = AddClassCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.isHidden = true
    }
    
    private let addDirectCollectionView = AddDirectCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.isHidden = true
    }
    
    private let substituteTimetableModalViewController = SubstituteTimetableModalViewController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.modalTransitionStyle = .crossDissolve
    }
    
    private let selectDeptModalViewController = SelectDeptModalViewController().then { _ in
    }
    
    private let deleteLectureModalViewController: DeleteLectureModalViewController = DeleteLectureModalViewController().then { _ in
    }
    
    private let containerView = UIView().then { _ in
    }
    
    private let didTapCellLectureView = UIView().then {
        $0.isUserInteractionEnabled = false
    }
    
    // MARK: - Initialization
    
    init(viewModel: TimetableViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "시간표"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureView()
        inputSubject.send(.fetchMySemester)
        print(KeychainWorker.shared.read(key: .access))
        semesterSelectButton.addTarget(self, action: #selector(modifySemesterButtonTapped), for: .touchUpInside)
        downloadImageButton.addTarget(self, action: #selector(downloadTimetableAsImage), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavigationBar(style: .fill)
    }
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case let .updateLectureList(lectureList):
                self?.addClassCollectionView.setUpLectureList(lectureList: lectureList)
            case let .showingSelectedFrame(semester, frameName):
                self?.updateSemesterButtonText(semester: semester, frameName: frameName)
            case let .updateMyFrame(lectureList):
                self?.updateTimetable(lectureData: lectureList)
                self?.addClassCollectionView.setUpMyLecture(myLectureList: lectureList)
                self?.setUpCollectionViewHeight(lectureList)
            }
        }.store(in: &subscriptions)
        
        // MARK: CLASS
        
        addClassCollectionView.completeButtonPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.didTapCellLectureView.subviews.forEach {
                $0.removeFromSuperview()
            }
            self.view.endEditing(true)
            self.toggleCollectionView(collectionView: self.addClassCollectionView, animate: true)
            
        }.store(in: &subscriptions)
        
        addClassCollectionView.addDirectButtonPublisher.sink { [weak self] in
            self?.didTapCellLectureView.subviews.forEach {
                $0.removeFromSuperview()
            }
            self?.addClassCollectionView.isHidden = true
            self?.addDirectCollectionView.isHidden = false
        }.store(in: &subscriptions)
        
        addClassCollectionView.modifyClassButtonPublisher.sink { [weak self] lecture in
            guard let self = self else { return }
            self.didTapCellLectureView.subviews.forEach {
                $0.removeFromSuperview()
            }
            if lecture.1 && viewModel.checkDuplicatedClassTime(classTime: lecture.0.classTime){
                substituteTimetableModalViewController.configure(lectureData: lecture.0)
                self.present(substituteTimetableModalViewController, animated: true)
            } else {
                self.inputSubject.send(.modifyLecture(lecture.0, lecture.1))
            }
        }.store(in: &subscriptions)
        
        addClassCollectionView.filterButtonPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.present(self.selectDeptModalViewController, animated: false)
        }.store(in: &subscriptions)
        
        addClassCollectionView.didTapCellPublisher.sink { [weak self] (selectedLecture, filteredLectures) in
            guard let self = self else { return }
            
            self.didTapCellLectureView.subviews.forEach {
                $0.removeFromSuperview()
            }
            if let selectedLecture = selectedLecture {
                self.addLectureHighlightView(for: selectedLecture, isDashed: false)
            }
            filteredLectures.forEach { lecture in
                self.addLectureHighlightView(for: lecture, isDashed: true)
            }
        }.store(in: &subscriptions)
        
        // MARK: DIRECT
        
        addDirectCollectionView.addClassButtonPublisher.sink { [weak self] in
            self?.addClassCollectionView.isHidden = false
            self?.addDirectCollectionView.isHidden = true
        }.store(in: &subscriptions)
        
        
        addDirectCollectionView.completeButtonPublisher.sink { [weak self] item in
            
            guard let self = self else { return }
            
            self.toggleCollectionView(collectionView: self.addDirectCollectionView, animate: true)
            if viewModel.checkDuplicatedClassTime(classTime: item.1) {
                substituteTimetableModalViewController.configure(customLecture: (item.0, item.1))
                self.present(substituteTimetableModalViewController, animated: true)
            } else {
                self.inputSubject.send(.postCustomLecture(item.0, item.1))
            }
        }.store(in: &subscriptions)
        
        
        // MARK: ETC
        
        deleteLectureView.completeButtonPublisher.sink { [weak self] in
            self?.deleteLectureView.isHidden = true
            
        }.store(in: &subscriptions)
        
        deleteLectureView.deleteButtonPublisher.sink { [weak self] lecture in
            guard let self = self else { return }
            self.deleteLectureView.isHidden = true
            deleteLectureModalViewController.setMessageLabelText(lectureData: lecture)
            self.present(deleteLectureModalViewController, animated: false)
        }.store(in: &subscriptions)
        
        timetableCollectionView.heightChangedPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.timetableCollectionView.snp.updateConstraints { make in
                make.height.equalTo(self.timetableCollectionView.calculateDynamicHeight())
            }
        }.store(in: &subscriptions)
        
        selectDeptModalViewController.selectedDeptPublisher.sink { [weak self] dept in
            self?.addClassCollectionView.setUpSelectedDept(dept: dept)
        }.store(in: &subscriptions)
        
        deleteLectureModalViewController.deleteButtonPublisher.sink { [weak self] lecture in
            self?.inputSubject.send(._deleteLecture(lecture))
        }.store(in: &subscriptions)
        
        substituteTimetableModalViewController.substituteButtonPublisher.sink { [weak self] response in
            guard let self = self else { return }
            
            if let lectureData = response as? LectureData {
                    self.viewModel.performLectureModification(lectureData: lectureData)
                        .sink(receiveCompletion: { _ in
                            self.viewModel.selectedFrameId = self.viewModel.selectedFrameId
                        }, receiveValue: { _ in })
                        .store(in: &self.subscriptions)
                    
                } else if let customLecture = response as? (String, [Int]) {
                    self.viewModel.performCustomLectureModification(
                        lectureName: customLecture.0,
                        lectureTime: customLecture.1
                    ).sink(receiveCompletion: { _ in
                        self.viewModel.selectedFrameId = self.viewModel.selectedFrameId
                    }, receiveValue: { _ in })
                    .store(in: &self.subscriptions)
                }
        }.store(in: &subscriptions)

        
    }
    
}

extension TimetableViewController {
    private func addLectureHighlightView(for lecture: SemesterLecture, isDashed: Bool) {
        
        let groupedByDay = Dictionary(grouping: lecture.classTime) { $0 / 100 }
        
        for (day, times) in groupedByDay {
            let continuousRanges = splitIntoContinuousRanges(times)
            
            for range in continuousRanges {
                if let firstTime = range.first {
                    let width = Int(containerView.frame.width / 5)
                    let height = 35
                    
                    let highlightView = UIView()
                    highlightView.backgroundColor = .clear
                    
                    if isDashed {
                        let dashedBorder = CAShapeLayer()
                        dashedBorder.strokeColor = UIColor.appColor(.neutral500).cgColor
                        dashedBorder.fillColor = UIColor.clear.cgColor
                        dashedBorder.lineDashPattern = [6, 4]
                        dashedBorder.lineWidth = 1.0
                        highlightView.layer.addSublayer(dashedBorder)
                        highlightView.layoutIfNeeded()
                        dashedBorder.path = UIBezierPath(rect: highlightView.bounds).cgPath
                        dashedBorder.frame = highlightView.bounds
                    } else {
                        highlightView.layer.borderWidth = 1.0
                        highlightView.layer.borderColor = UIColor.appColor(.neutral500).cgColor
                    }
                    
                    didTapCellLectureView.addSubview(highlightView)
                    
                    highlightView.snp.makeConstraints { make in
                        make.height.equalTo(height * range.count - 2)
                        make.top.equalTo(containerView.snp.top).offset(height * (firstTime % 100) + 2)
                        let sectionWidth = containerView.frame.width / 5
                        let leadingOffset = sectionWidth * CGFloat(day)
                        let trailingOffset = sectionWidth * CGFloat(day + 1)
                        make.leading.equalTo(containerView.snp.leading).offset(leadingOffset + 1)
                        make.trailing.equalTo(containerView.snp.leading).offset(trailingOffset - 1)
                    }
                    
                    // 레이아웃 업데이트 후 점선 테두리 보정
                    if isDashed {
                        highlightView.layoutIfNeeded()
                        if let dashedBorder = highlightView.layer.sublayers?.first as? CAShapeLayer {
                            dashedBorder.path = UIBezierPath(rect: highlightView.bounds).cgPath
                            dashedBorder.frame = highlightView.bounds
                        }
                    }
                }
            }
        }
    }
    
    
    private func setUpCollectionViewHeight(_ lectureList: [LectureData]) {
        // 강의 시간에서 마지막 2자리 추출
        let lastTwoDigits = lectureList.flatMap { $0.classTime.map { $0 % 100 } }
        
        // 마지막 2자리 숫자의 최댓값 구하기
        let maxLastTwoDigits = lastTwoDigits.max() ?? 0 // 실패 시 기본값 0 처리
        
        // 마지막 2자리 최댓값을 2로 나눈 값 계산
        let dividedValue = maxLastTwoDigits / 2
        
        // 17과 (9 + dividedValue) 중 최댓값 계산
        let upperLimit = max(17, 9 + dividedValue)
        
        // 9부터 upperLimit까지의 배열 생성
        let resultArray = Array(9...upperLimit)
        
        // timetableCollectionView 업데이트
        timetableCollectionView.updateLecture(lectureTime: resultArray)
        timetableCollectionView.snp.updateConstraints { make in
            make.height.equalTo(timetableCollectionView.calculateDynamicHeight())
        }
    }
    
    
    @objc private func modifySemesterButtonTapped() {
        navigationController?.pushViewController(FrameListViewController(viewModel: viewModel), animated: true)
    }
    private func updateTimetable(lectureData: [LectureData]) {
        print(lectureData)
        
        let existingLectureViews = containerView.subviews.compactMap { $0 as? LectureView }
        let existingLectureInfos = Set(existingLectureViews.map { $0.info })
        
        // 새 강의와 제거된 강의 필터링
        let addedLectures = lectureData.filter { !existingLectureInfos.contains($0) }
        let removedLectureViews = existingLectureViews.filter { !lectureData.contains($0.info) }
        
        // 사용된 색상 추적
        var usedColors: [UIColor] = existingLectureViews.compactMap { $0.backgroundColor }
        
        // 제거된 강의 색상 복원
        for lectureView in removedLectureViews {
            if let removedColor = lectureView.backgroundColor {
                usedColors.removeAll { $0 == removedColor }
            }
            lectureView.removeFromSuperview()
        }
        
        // 강의 ID별 색상 매핑
        var lectureColorMap: [Int: (UIColor, UIColor)] = [:]
        for lectureView in existingLectureViews {
            let lecture = lectureView.info
            if let bodyColor = lectureView.backgroundColor, let headerColor = lectureView.separateView.backgroundColor {
                lectureColorMap[lecture.id] = (bodyColor, headerColor)
            }
        }
        
        // 미사용 색상 추적
        var unusedColorPairs: [(UIColor, UIColor)] = timetableColors.compactMap { colorPair in
            let bodyColor = UIColor.timetableColor(_name: colorPair.0)
            let headerColor = UIColor.timetableColor(_name: colorPair.1)
            return usedColors.contains(bodyColor) ? nil : (bodyColor, headerColor)
        }
        
        // 새 강의 추가
        for lecture in addedLectures {
            let groupedByDay = Dictionary(grouping: lecture.classTime) { $0 / 100 }
            
            for (day, times) in groupedByDay {
                let separatedTimes = splitIntoContinuousRanges(times)
                
                for range in separatedTimes {
                    if let firstTime = range.first {
                        let width = Int(containerView.frame.width / 5) + 1
                        let height = 35
                        
                        // 색상 재사용 또는 할당
                        let colorPair: (UIColor, UIColor)
                        if let existingColor = lectureColorMap[lecture.id] {
                            colorPair = existingColor
                        } else {
                            // 모든 색상을 사용한 경우 재순환
                            if unusedColorPairs.isEmpty {
                                unusedColorPairs = timetableColors.compactMap { colorPair in
                                    let bodyColor = UIColor.timetableColor(_name: colorPair.0)
                                    let headerColor = UIColor.timetableColor(_name: colorPair.1)
                                    return (bodyColor, headerColor)
                                }
                            }
                            
                            colorPair = unusedColorPairs.removeFirst()
                            lectureColorMap[lecture.id] = colorPair
                        }
                        
                        let bodyColor = colorPair.0
                        let headerColor = colorPair.1
                        
                        // 강의 뷰 생성
                        let lectureView = LectureView(info: lecture, color: bodyColor)
                        lectureView.separateView.backgroundColor = headerColor
                        
                        // UI 설정
                        lectureView.backgroundColor = bodyColor
                        lectureView.lectureNameLabel.backgroundColor = bodyColor
                        lectureView.professorNameLabel.backgroundColor = bodyColor
                        
                        // 탭 동작 추가
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLectureTap(_:)))
                        lectureView.addGestureRecognizer(tapGesture)
                        lectureView.isUserInteractionEnabled = true
                        
                        containerView.addSubview(lectureView)
                        
                        lectureView.snp.makeConstraints { make in
                            make.height.equalTo(height * range.count - 2)
                            make.top.equalTo(containerView.snp.top).offset(height * (firstTime % 100) + 2)
                            
                            let sectionWidth = containerView.frame.width / 5
                            let leadingOffset = sectionWidth * CGFloat(day)
                            let trailingOffset = sectionWidth * CGFloat(day + 1)
                            
                            make.leading.equalTo(containerView.snp.leading).offset(leadingOffset + 1)
                            make.trailing.equalTo(containerView.snp.leading).offset(trailingOffset - 1)
                        }
                        
                        if range.count == 1 {
                            lectureView.lectureNameLabel.snp.updateConstraints { make in
                                make.height.equalTo(30)
                            }
                        }
                        
                        // 새로 추가된 색상 기록
                        usedColors.append(bodyColor)
                    }
                }
            }
        }
    }

 
    @objc private func handleLectureTap(_ sender: UITapGestureRecognizer) {
        if let tappedView = sender.view as? LectureView {
            deleteLectureView.configure(lecture: tappedView.info)
            deleteLectureView.isHidden = false
        }
    }
    
    // Helper: 연속된 시간대를 분리
    func splitIntoContinuousRanges(_ times: [Int]) -> [[Int]] {
        let sortedTimes = times.sorted() // 정렬하여 연속 여부 확인
        var result: [[Int]] = []
        var currentRange: [Int] = []
        
        for time in sortedTimes {
            if let last = currentRange.last, time == last + 1 {
                currentRange.append(time) // 연속된 시간
            } else {
                if !currentRange.isEmpty {
                    result.append(currentRange) // 이전 범위를 결과에 추가
                }
                currentRange = [time] // 새로운 범위 시작
            }
        }
        if !currentRange.isEmpty {
            result.append(currentRange) // 마지막 범위 추가
        }
        return result
    }
    
    
    private func updateSemesterButtonText(semester: String, frameName: String?) {
        if let frameName = frameName {
            semesterSelectButton.setTitle("\(semester.reverseFormatSemester()) / \(frameName)", for: .normal)
        } else {
            semesterSelectButton.setTitle("\(semester)", for: .normal)
        }
    }
    @objc private func modifyTimetableButtonTapped() {
        
        
        if addClassCollectionView.isHidden && addDirectCollectionView.isHidden {
            toggleCollectionView(collectionView: addClassCollectionView, animate: true)
        } else {
            let selectedCollectionView = addClassCollectionView.isHidden ? addDirectCollectionView : addClassCollectionView
            toggleCollectionView(collectionView: selectedCollectionView, animate: true)
        }
    }
    
    private func toggleCollectionView(collectionView: UICollectionView, animate: Bool) {
        collectionView.isHidden.toggle()
    }
}

extension TimetableViewController {
    @objc private func downloadTimetableAsImage() {
        let renderer = UIGraphicsImageRenderer(size: timetableCollectionView.bounds.size)
        let combinedImage = renderer.image { context in
            timetableCollectionView.drawHierarchy(in: timetableCollectionView.bounds, afterScreenUpdates: true)
            let containerFrame = CGRect(
                origin: CGPoint(x: containerView.frame.origin.x - 24,
                                y: containerView.frame.origin.y),
                size: containerView.bounds.size
            )
            containerView.drawHierarchy(in: containerFrame, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(combinedImage, self, #selector(saveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    private func captureViewAsImage(view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
    
    private func mergeImages(topImage: UIImage, bottomImage: UIImage) -> UIImage {
        let newSize = CGSize(width: max(topImage.size.width, bottomImage.size.width),
                             height: topImage.size.height + bottomImage.size.height)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { context in
            topImage.draw(at: .zero)
            bottomImage.draw(at: CGPoint(x: 0, y: topImage.size.height))
        }
    }
    
    @objc private func saveCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "저장 실패", message: "이미지를 갤러리에 저장할 권한이 없습니다. 권한을 추가해 주세요.")
        } else {
            showAlert(title: "저장 완료", message: "시간표 이미지가 사진 앱에 저장되었습니다.")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
}

extension TimetableViewController {
    
    private func setUpLayOuts() {
        [scrollView, semesterSelectButton, downloadImageButton, addClassCollectionView, addDirectCollectionView, deleteLectureView].forEach {
            view.addSubview($0)
        }
        [timetableCollectionView, containerView, emptyView, didTapCellLectureView].forEach {
            scrollView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        semesterSelectButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.width.equalTo(134)
            make.height.equalTo(32)
        }
        downloadImageButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.width.equalTo(134)
            make.height.equalTo(32)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(semesterSelectButton.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
        }
        timetableCollectionView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(646)
            make.bottom.equalTo(scrollView.snp.bottom)
        }
        addClassCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY)
            make.leading.trailing.bottom.equalToSuperview()
        }
        addDirectCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(addClassCollectionView)
        }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(timetableCollectionView.snp.top).offset(16)
            make.leading.equalTo(timetableCollectionView.snp.leading).offset(18)
            make.trailing.bottom.equalTo(timetableCollectionView)
        }
        didTapCellLectureView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        deleteLectureView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(220)
        }
        emptyView.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width)
        }
    }
    private func setUpNavigationBar() {
        let modifyTimetableButton = UIBarButtonItem(image: UIImage.appImage(asset: .write), style: .plain, target: self, action: #selector(modifyTimetableButtonTapped))
        navigationItem.rightBarButtonItem = modifyTimetableButton
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpNavigationBar()
        self.view.backgroundColor = .systemBackground
    }
}
