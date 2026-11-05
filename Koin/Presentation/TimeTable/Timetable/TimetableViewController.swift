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
    private var sheetContentView: TimetableBottomSheetContentView?
    private weak var sheetController: KoinBottomSheetController?
    private var pendingSheetContent: (view: UIView, height: CGFloat?)?
    private var isResettingTimetableInset = false
    private var previewClassTimes: [Int] = []
    
    
    // MARK: - UI Components
    
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
    
    
    private let scrollView = UIScrollView()
    
    private let deleteLectureView = DeleteLectureView()
    
    private let semesterSelectButton = UIButton()
    private let downloadImageButton = UIButton()
    private let gridView = UIView()
    private let timetableCollectionView = TimetableCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let addClassCollectionView = AddClassCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let addDirectCollectionView = AddDirectCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let containerView = UIView()
    private let didTapCellLectureView = UIView()
    private let dayColumnGuides = (0..<TimetableGridMetrics.dayCount).map { _ in UILayoutGuide() }
    
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

    deinit {
        // 요청 중에 화면을 나가도 로딩 표시가 남지 않게 한다.
        IndicatorView.dismiss()
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureView()
        // 진입 화면이 넘겨 준 메인 시간표를 서버 응답 전에 먼저 그린다.
        if let frame = viewModel.initialFrame {
            showMyFrame(frame.lectures)
            updateSemesterButtonText(semester: frame.semester, frameName: frame.frameName)
        }
        semesterSelectButton.addTarget(self, action: #selector(modifySemesterButtonTapped), for: .touchUpInside)
        downloadImageButton.addTarget(self, action: #selector(downloadTimetableAsImage), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
        inputSubject.send(.fetchMySemester)
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
                self?.showMyFrame(lectureList)
            case let .showToast(message, intent):
                self?.showToastMessage(message: message, intent: intent)
            }
        }.store(in: &subscriptions)
        
        viewModel.$isLoading.removeDuplicates().sink { isLoading in
            // 목록 화면도 같은 ViewModel을 쓰므로 여기서 한 번만 표시한다.
            isLoading ? IndicatorView.show(dimmed: false) : IndicatorView.dismiss()
        }.store(in: &subscriptions)

        viewModel.$canUseStudentFeatures.sink { [weak self] canUse in
            guard let self else { return }
            let isRestricted = !canUse
            self.containerView.isHidden = isRestricted
            if isRestricted {
                self.pendingSheetContent = nil
                self.dismissTimetableSheet()
            }
        }.store(in: &subscriptions)

        // MARK: CLASS
        
        addClassCollectionView.completeButtonPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.didTapCellLectureView.subviews.forEach {
                $0.removeFromSuperview()
            }
            self.dismissTimetableSheet()
            self.inputSubject.send(.selectedDepartment(nil))
            
        }.store(in: &subscriptions)
        
        addClassCollectionView.addDirectButtonPublisher.sink { [weak self] in
            self?.didTapCellLectureView.subviews.forEach {
                $0.removeFromSuperview()
            }
            guard let self else { return }
            self.addDirectCollectionView.beginAdding()
            self.showTimetableSheet(content: self.addDirectCollectionView)
            self.updateCustomLectureHighlights(self.addDirectCollectionView.request)
        }.store(in: &subscriptions)
        
        addClassCollectionView.modifyClassButtonPublisher.sink { [weak self] lecture in
            guard let self, self.requireStudentAccess() else { return }
            self.didTapCellLectureView.subviews.forEach {
                $0.removeFromSuperview()
            }
            self.previewClassTimes = []
            self.setUpCollectionViewHeight(self.viewModel.lectureData)
            if lecture.1 && viewModel.checkDuplicatedClassTime(classTime: lecture.0.classTime){
                self.presentSubstituteTimetableModal(lectureData: lecture.0)
            } else {
                self.inputSubject.send(.modifyLecture(lecture.0, lecture.1))
            }
        }.store(in: &subscriptions)
        
        addClassCollectionView.filterButtonPublisher.sink { [weak self] in
            self?.presentSelectDeptModal()
        }.store(in: &subscriptions)
        
        addClassCollectionView.didTapCellPublisher.sink { [weak self] (selectedLecture, filteredLectures) in
            guard let self = self else { return }
            
            self.didTapCellLectureView.subviews.forEach {
                $0.removeFromSuperview()
            }
            self.previewClassTimes = (selectedLecture?.classTime ?? []) + filteredLectures.flatMap(\.classTime)
            self.setUpCollectionViewHeight(self.viewModel.lectureData)
            if let selectedLecture = selectedLecture {
                self.addLectureHighlightView(for: selectedLecture, isDashed: false)
            }
            filteredLectures.forEach { lecture in
                self.addLectureHighlightView(for: lecture, isDashed: true)
            }
        }.store(in: &subscriptions)
        
        // MARK: DIRECT
        
        addDirectCollectionView.addClassButtonPublisher.sink { [weak self] in
            guard let self else { return }
            if self.addDirectCollectionView.isEditing {
                // 수정 취소는 직접 일정 상세 시트로 돌아간다. 상세 시트는 탭한 강의로 이미 채워져 있다.
                self.showTimetableSheet(content: self.deleteLectureView)
                self.addDirectCollectionView.resetForm()
            } else {
                self.addDirectCollectionView.resetForm()
                self.showTimetableSheet(content: self.addClassCollectionView)
            }
        }.store(in: &subscriptions)

        addDirectCollectionView.weekdayDropdownPublisher.sink { [weak self] anchor, content in
            // 시트 안이 아닌 시트의 host(tab·nav)에서 띄워 시트 위에 그리고, 화면 기준으로 위/아래를 정한다.
            guard let self else { return }
            (self.sheetController?.parent ?? self).presentDropdown(
                anchor: anchor,
                content: content,
                configuration: .init(direction: .auto(downSpacing: 4, upSpacing: 4), shadow: .shadow2)
            )
        }.store(in: &subscriptions)

        addDirectCollectionView.closeButtonPublisher.sink { [weak self] in
            self?.dismissTimetableSheet()
        }.store(in: &subscriptions)

        addDirectCollectionView.completeButtonPublisher.sink { [weak self] lecture in
            // 닫히는 애니메이션 중 다시 탭해도 한 번만 저장한다.
            guard let self, self.sheetController?.isDismissing != true, self.requireStudentAccess() else { return }
            if let conflict = self.viewModel.conflictingLecture(with: lecture) {
                self.presentCustomOverlap(conflict)
                return
            }
            self.dismissTimetableSheet()
            self.inputSubject.send(.saveCustomLecture(lecture))
        }.store(in: &subscriptions)

        addDirectCollectionView.requestChangedPublisher.sink { [weak self] request in
            guard let self, let sheetContent = self.sheetContentView,
                  !self.isResettingTimetableInset,
                  self.addDirectCollectionView.superview === sheetContent else { return }
            self.updateCustomLectureHighlights(request)
        }.store(in: &subscriptions)

        addDirectCollectionView.requestChangedPublisher
            .map { $0.classInfos.count }
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self, let sheetContent = self.sheetContentView,
                      !self.isResettingTimetableInset,
                      self.addDirectCollectionView.superview === sheetContent else { return }
                sheetContent.delegate?.invalidateHeight(animated: true)
            }.store(in: &subscriptions)

        // MARK: ETC
        
        deleteLectureView.completeButtonPublisher.sink { [weak self] in
            self?.dismissTimetableSheet()
            
        }.store(in: &subscriptions)
        
        deleteLectureView.editButtonPublisher.sink { [weak self] lecture in
            guard let self, self.requireStudentAccess(), lecture.lectureId == nil else { return }
            self.addDirectCollectionView.beginEditing(lecture)
            self.showTimetableSheet(content: self.addDirectCollectionView)
            self.updateCustomLectureHighlights(self.addDirectCollectionView.request)
        }.store(in: &subscriptions)

        deleteLectureView.deleteButtonPublisher.sink { [weak self] lecture in
            guard let self, self.requireStudentAccess() else { return }
            self.dismissTimetableSheet { [weak self] in
                self?.presentDeleteLectureModal(lecture: lecture)
            }
        }.store(in: &subscriptions)
        
        timetableCollectionView.heightChangedPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.gridView.snp.updateConstraints { make in
                make.height.equalTo(self.timetableCollectionView.requiredHeight)
            }
        }.store(in: &subscriptions)
        
    }
}

extension TimetableViewController {
    private func requireStudentAccess() -> Bool {
        requireTimetableStudentAccess()
    }

    private func presentSubstituteTimetableModal(lectureData: LectureData) {
        guard requireStudentAccess() else { return }
        let viewController = makeSubstituteTimetableModal()
        viewController.configure(lectureData: lectureData)
        present(viewController, animated: true)
    }

    private func makeSubstituteTimetableModal() -> SubstituteTimetableModalViewController {
        SubstituteTimetableModalViewController { [weak self] response in
            self?.handleSubstituteResponse(response)
        }
    }

    private func handleSubstituteResponse(_ response: Any) {
        guard requireStudentAccess() else { return }
        let completion: (Subscribers.Completion<Never>) -> Void = { [weak self] _ in
            self?.viewModel.selectedFrameId = self?.viewModel.selectedFrameId
        }
        if let lectureData = response as? LectureData {
            viewModel.performLectureModification(lectureData: lectureData)
                .sink(receiveCompletion: completion, receiveValue: { _ in })
                .store(in: &subscriptions)

        }
    }

    private func presentSelectDeptModal() {
        guard requireStudentAccess() else { return }
        let modalViewController = SelectDeptModalViewController(
            departments: viewModel.departments,
            selectedDapartment: viewModel.selectedDepartment
        ) { [weak self] department in
            self?.addClassCollectionView.setUpSelectedDept(dept: department)
            self?.inputSubject.send(.selectedDepartment(department))
        }
        present(modalViewController, animated: true)
    }

    private func presentDeleteLectureModal(lecture: LectureData) {
        guard requireStudentAccess() else { return }
        let modalViewController = DeleteLectureModalViewController(lectureData: lecture) { [weak self] lecture in
            self?.inputSubject.send(._deleteLecture(lecture))
        }
        present(modalViewController, animated: true)
    }
}

extension TimetableViewController {
    private func presentCustomOverlap(_ lecture: LectureData) {
        guard presentedViewController == nil else { return }
        view.endEditing(true)
        let modal = KoinModalViewController(configuration: .init(
            appearance: .new,
            content: .titles(
                mainTitleText: "일정이 중복돼요.",
                mainTitleStyle: .init(textColor: .neutral800, font: .pretendardSemiBold, fontSize: 16),
                subTitleText: "해당 일정이 \(lecture.name)(\(lecture.classTime.timeLabelText()))과\n중복됩니다. 다른 시간을 선택해주세요.",
                subTitleStyle: .init(textColor: .neutral600, font: .pretendardRegular, fontSize: 14)
            ),
            button: .singleButton(title: "확인", style: .init(textColor: .neutral0, font: .pretendardMedium, fontSize: 15, backgroundColor: .new500, cornerRadius: 4))
        ))
        present(modal, animated: true)
    }

    private func updateCustomLectureHighlights(_ request: TimetableLecture) {
        let classTime = Array(Set(request.classInfos.flatMap { $0.classTime ?? [] })).sorted()
        previewClassTimes = classTime
        setUpCollectionViewHeight(viewModel.lectureData)
        view.layoutIfNeeded()
        didTapCellLectureView.subviews.forEach { $0.removeFromSuperview() }
        let lecture = SemesterLecture(
            id: -1, code: "", name: request.classTitle, grades: "0", lectureClass: "",
            regularNumber: nil, professor: request.professor ?? "", department: "", target: "",
            isEnglish: "", designScore: "", isElearning: "", classTime: classTime
        )
        addLectureHighlightView(for: lecture, isDashed: false)
    }

    private func addLectureHighlightView(for lecture: SemesterLecture, isDashed: Bool) {
        let groupedByDay = Dictionary(grouping: lecture.classTime) { $0 / 100 }
        for (day, times) in groupedByDay where dayColumnGuides.indices.contains(day) {
            for range in splitIntoContinuousRanges(times) {
                guard let firstTime = range.first else { continue }
                let highlightView = TimetableSlotHighlightView(isDashed: isDashed)
                didTapCellLectureView.addSubview(highlightView)
                constrainSlotView(highlightView, day: day, firstTime: firstTime, slotCount: range.count)
            }
        }
    }

    private func constrainSlotView(_ slotView: UIView, day: Int, firstTime: Int, slotCount: Int) {
        let column = dayColumnGuides[day]
        slotView.snp.makeConstraints {
            $0.leading.equalTo(column.snp.leading)
            $0.trailing.equalTo(column.snp.trailing).offset(-TimetableGridMetrics.lineWidth)
            $0.top.equalTo(containerView.snp.top).offset(CGFloat(firstTime % 100) * TimetableGridMetrics.slotHeight)
            $0.height.equalTo(CGFloat(slotCount) * TimetableGridMetrics.slotHeight - TimetableGridMetrics.lineWidth)
        }
    }

    private func setUpCollectionViewHeight(_ lectureList: [LectureData]) {
        let upperLimit = Self.lastVisibleHour(for: lectureList.flatMap(\.classTime) + previewClassTimes)
        timetableCollectionView.updateLecture(lectureTime: Array(9...upperLimit))
    }

    /// 시간 코드는 09:00부터 30분 단위. 기본은 18:00까지, 늦은 일정은 최대 24:00까지 표시한다.
    private static func lastVisibleHour(for classTimes: [Int]) -> Int {
        let lastSlot = classTimes.map { $0 % 100 }.max() ?? 0
        return min(23, max(17, 9 + lastSlot / 2))
    }

    @objc private func modifySemesterButtonTapped() {
        // 바텀시트가 떠 있으면 이동하지 않고 시트만 닫는다.
        guard sheetContentView == nil else {
            dismissTimetableSheet()
            return
        }
        navigationController?.pushViewController(FrameListViewController(viewModel: viewModel), animated: true)
    }
    private func updateTimetable(lectureData: [LectureData]) {
        
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
            
            for (day, times) in groupedByDay where dayColumnGuides.indices.contains(day) {
                let separatedTimes = splitIntoContinuousRanges(times)
                
                for range in separatedTimes {
                    if let firstTime = range.first {
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
                        let lectureView = LectureView(info: lecture, color: bodyColor, headerColor: headerColor)

                        // 탭 동작 추가
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLectureTap(_:)))
                        lectureView.addGestureRecognizer(tapGesture)
                        lectureView.isUserInteractionEnabled = true
                        
                        containerView.addSubview(lectureView)
                        
                        constrainSlotView(lectureView, day: day, firstTime: firstTime, slotCount: range.count)

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
            showTimetableSheet(content: deleteLectureView)
        }
    }
    
    // Helper: 연속된 시간대를 분리
    func splitIntoContinuousRanges(_ times: [Int]) -> [[Int]] {
        let sortedTimes = Set(times).sorted() // 정렬하여 연속 여부 확인
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
    
    
    private func showMyFrame(_ lectureList: [LectureData]) {
        // 새 강의 뷰를 바로 배치해 이후 시트 닫힘 애니메이션에 끌려가 움직이지 않게 한다.
        UIView.performWithoutAnimation {
            updateTimetable(lectureData: lectureList)
            addClassCollectionView.setUpMyLecture(myLectureList: lectureList)
            setUpCollectionViewHeight(lectureList)
            view.layoutIfNeeded()
        }
    }

    private func updateSemesterButtonText(semester: String, frameName: String?) {
        let title = frameName.map { "\(semester.reverseFormatSemester()) / \($0)" } ?? semester
        TimetableButtonTitle.set(title, on: semesterSelectButton, font: .pretendardRegular, size: 14, color: .neutral800, lineBreakMode: .byTruncatingTail)
    }
    @objc private func modifyTimetableButtonTapped() {
        guard requireStudentAccess() else { return }
        addClassCollectionView.setUpSelectedDept(dept: nil)
        inputSubject.send(.selectedDepartment(nil))
        
        showTimetableSheet(content: addClassCollectionView)
    }

    private func showTimetableSheet(content: UIView, height: CGFloat? = nil) {
        guard requireStudentAccess() else { return }
        if content !== addDirectCollectionView, !previewClassTimes.isEmpty {
            previewClassTimes = []
            setUpCollectionViewHeight(viewModel.lectureData)
        }
        didTapCellLectureView.subviews.forEach { $0.removeFromSuperview() }
        if sheetController?.isDismissing == true {
            pendingSheetContent = (content, height)
            return
        }
        // 수업 추가만 fullscreen을 허용한다. 직접 일정 추가·수정은 드래그·키보드에도 콘텐츠 높이를 유지한다.
        let allowsFullScreen = content === addClassCollectionView
        if let sheetContentView {
            sheetController?.configuration.behavior.expandToFullScreenOnDrag = allowsFullScreen
            sheetController?.configuration.behavior.expandToFullScreenOnKeyboard = allowsFullScreen
            sheetContentView.show(content: content, height: height)
            if !allowsFullScreen {
                // 드래그로 펼친 수업 추가에서 넘어와도 콘텐츠 높이로 연다.
                sheetContentView.delegate?.setFullScreen(false, animated: true)
            }
            return
        }

        isResettingTimetableInset = false
        let sheetContent = TimetableBottomSheetContentView(content: content, height: height)
        sheetContentView = sheetContent
        var configuration = KoinBottomSheetConfiguration()
        // 기본 높이에서는 화면 속 뷰처럼 바깥 상호작용·pop이 되고, fullscreen에서만 dim과 함께 막힌다.
        configuration.style = .nonModal
        configuration.behavior.expandToFullScreenOnDrag = allowsFullScreen
        configuration.behavior.expandToFullScreenOnKeyboard = allowsFullScreen
        configuration.showsShadow = true
        configuration.onTargetFrameChange = { [weak self, weak sheetContent] frame in
            guard let self, let sheetContent, self.sheetContentView === sheetContent,
                  !self.isResettingTimetableInset else { return }
            // 키보드와 fullscreen 전환도 시트가 멈출 상단을 기준으로 가려진 영역을 비운다.
            let bottomInset = max(0, self.scrollView.frame.maxY - self.view.convert(frame, from: nil).minY)
            self.scrollView.contentInset.bottom = bottomInset
            self.scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
        }
        configuration.onWillDismiss = { [weak self] in
            self?.resetTimetableBottomInset(animated: true)
        }
        configuration.onDismiss = { [weak self, weak sheetContent] in
            // 기존 컬렉션의 검색/입력 상태를 유지하되 다음 presentation에는 새 래퍼를 쓴다.
            sheetContent?.removeContent()
            guard let self, self.sheetContentView === sheetContent else { return }
            self.sheetContentView = nil
            self.sheetController = nil
            self.addDirectCollectionView.resetForm()
            self.resetTimetableBottomInset(animated: true)
            self.didTapCellLectureView.subviews.forEach { $0.removeFromSuperview() }
            if let pending = self.pendingSheetContent {
                self.pendingSheetContent = nil
                self.showTimetableSheet(content: pending.view, height: pending.height)
            }
        }
        sheetController = presentBottomSheet(sheetContent, configuration: configuration)
        if sheetController == nil {
            sheetContent.removeContent()
            sheetContentView = nil
        }
    }

    private func dismissTimetableSheet(completion: (() -> Void)? = nil) {
        guard let delegate = sheetContentView?.delegate else {
            completion?()
            return
        }
        delegate.dismiss(completion: completion)
    }

    private func resetTimetableBottomInset(animated: Bool) {
        // 키보드 및 시트의 닫힘 레이아웃이 해제 중인 inset을 다시 쓰지 않게 한다.
        isResettingTimetableInset = true
        guard scrollView.contentInset.bottom != 0 || scrollView.verticalScrollIndicatorInsets.bottom != 0 || !previewClassTimes.isEmpty else { return }
        let changes = { [weak self] in
            guard let self else { return }
            let offset = self.scrollView.contentOffset
            if !self.previewClassTimes.isEmpty {
                self.previewClassTimes = []
                self.setUpCollectionViewHeight(self.viewModel.lectureData)
                self.view.layoutIfNeeded()
            }
            self.scrollView.contentInset.bottom = 0
            self.scrollView.verticalScrollIndicatorInsets.bottom = 0
            let maximumOffsetY = max(
                -self.scrollView.adjustedContentInset.top,
                self.scrollView.contentSize.height + self.scrollView.adjustedContentInset.bottom - self.scrollView.bounds.height
            )
            self.scrollView.contentOffset = CGPoint(x: offset.x, y: min(offset.y, maximumOffsetY))
        }
        if animated {
            // 시트 닫힘 시작과 동시에 출렁임 없는 spring으로 시트를 따라간다.
            UIView.animate(
                springDuration: 0.3,
                bounce: 0,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: changes
            )
        } else {
            changes()
        }
    }
}

extension TimetableViewController {
    @objc private func downloadTimetableAsImage() {
        guard requireStudentAccess() else { return }
        view.layoutIfNeeded()
        // 저장 이미지는 그리드와 등록된 강의만 포함하고 입력 중인 가이드라인은 제외한다.
        let wasHighlightHidden = didTapCellLectureView.isHidden
        didTapCellLectureView.isHidden = true
        defer { didTapCellLectureView.isHidden = wasHighlightHidden }
        let renderer = UIGraphicsImageRenderer(size: gridView.bounds.size)
        let combinedImage = renderer.image { _ in
            gridView.drawHierarchy(in: gridView.bounds, afterScreenUpdates: true)
        }
        UIImageWriteToSavedPhotosAlbum(combinedImage, self, #selector(saveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func saveCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let modal = KoinModalViewController(configuration: .init(
                appearance: .primary,
                content: .titles(
                    mainTitleText: "저장실패",
                    subTitleText: "이미지를 갤러리에 저장할 권한이 없습니다\n권한을 추가해주세요."
                ),
                button: .singleButton(title: "확인")
            ))
            present(modal, animated: true)
        } else {
            showToastMessage(message: "시간표를 저장했어요")
        }
    }
}

extension TimetableViewController {
    
    private func setUpLayouts() {
        [scrollView, semesterSelectButton, downloadImageButton].forEach {
            view.addSubview($0)
        }
        scrollView.addSubview(gridView)
        // 가이드라인은 등록 강의 위에 놓아 겹치는 시간도 보이게 한다. 터치는 받지 않아 강의 탭은 그대로 동작한다.
        [timetableCollectionView, containerView, didTapCellLectureView].forEach { gridView.addSubview($0) }
        dayColumnGuides.forEach { containerView.addLayoutGuide($0) }
    }
    
    private func setUpConstraints() {
        semesterSelectButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(11)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.lessThanOrEqualTo(downloadImageButton.snp.leading).offset(-11)
            make.height.equalTo(38)
        }
        downloadImageButton.snp.makeConstraints { make in
            make.top.equalTo(semesterSelectButton)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(semesterSelectButton)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(semesterSelectButton.snp.bottom).offset(11)
            make.leading.trailing.bottom.equalToSuperview()
        }
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        gridView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide.snp.top)
            make.leading.equalTo(scrollView.contentLayoutGuide.snp.leading).offset(24)
            make.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing).offset(-24)
            make.height.equalTo(timetableCollectionView.requiredHeight)
            make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
        }
        timetableCollectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(timetableCollectionView.snp.top).offset(TimetableGridMetrics.headerHeight)
            make.leading.equalTo(timetableCollectionView.snp.leading).offset(TimetableGridMetrics.timeColumnWidth)
            make.trailing.bottom.equalTo(timetableCollectionView)
        }
        didTapCellLectureView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        for (index, column) in dayColumnGuides.enumerated() {
            column.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.width.equalTo(containerView).dividedBy(TimetableGridMetrics.dayCount)
                if index == 0 {
                    $0.leading.equalToSuperview()
                } else {
                    $0.leading.equalTo(dayColumnGuides[index - 1].snp.trailing)
                }
            }
        }
    }
    private func setUpNavigationBar() {
        let modifyTimetableButton = UIBarButtonItem(image: UIImage.appImage(asset: .timetableSquarePen), style: .plain, target: self, action: #selector(modifyTimetableButtonTapped))
        modifyTimetableButton.accessibilityLabel = "수업 추가"
        navigationItem.rightBarButtonItem = modifyTimetableButton
    }
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        view.backgroundColor = .appColor(.neutral0)
        gridView.backgroundColor = .appColor(.neutral0)
        gridView.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        gridView.layer.borderWidth = TimetableGridMetrics.lineWidth
        gridView.layer.cornerRadius = TimetableGridMetrics.cornerRadius
        gridView.clipsToBounds = true
        didTapCellLectureView.isUserInteractionEnabled = false
        [semesterSelectButton, downloadImageButton].forEach {
            $0.backgroundColor = .appColor(.neutral0)
            $0.layer.cornerRadius = 10
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.appColor(.neutral300).cgColor
            $0.clipsToBounds = true
            var configuration = UIButton.Configuration.plain()
            configuration.baseForegroundColor = .appColor(.neutral800)
            configuration.contentInsets = .init(top: 8, leading: 10, bottom: 8, trailing: 10)
            configuration.titleLineBreakMode = .byTruncatingTail
            $0.configuration = configuration
        }
        semesterSelectButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        downloadImageButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        TimetableButtonTitle.set("시간표 다운로드", on: downloadImageButton, font: .pretendardRegular, size: 14, color: .neutral800, lineBreakMode: .byTruncatingTail)
        downloadImageButton.configuration?.image = .appImage(asset: .timetableDownload)
        downloadImageButton.configuration?.imagePlacement = .trailing
        downloadImageButton.configuration?.imagePadding = 8
        setUpNavigationBar()
    }
}


private final class TimetableSlotHighlightView: UIView {
    // MARK: - Properties
    private let isDashed: Bool

    // MARK: - UI Components
    private let border = CAShapeLayer()

    init(isDashed: Bool) {
        self.isDashed = isDashed
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        border.frame = bounds
        border.path = UIBezierPath(rect: bounds.insetBy(
            dx: TimetableGridMetrics.lineWidth / 2,
            dy: TimetableGridMetrics.lineWidth / 2
        )).cgPath
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
    }

    private func setUpStyles() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        border.strokeColor = UIColor.appColor(isDashed ? .neutral500 : .new500).cgColor
        border.fillColor = UIColor.clear.cgColor
        border.lineWidth = TimetableGridMetrics.lineWidth
        border.lineDashPattern = isDashed ? [6, 4] : nil
    }

    private func setUpLayouts() {
        layer.addSublayer(border)
    }
}

/// 시간표 전용 어댑터. 기존 패널의 입력과 publisher를 유지한 채 Core 시트에 담는다.
private final class TimetableBottomSheetContentView: UIView, KoinBottomSheetContent {
    // MARK: - Properties
    weak var delegate: KoinBottomSheetDelegate?
    private var content: UIView
    private var preferredHeight: CGFloat?
    private var previousWidth: CGFloat = 0

    init(content: UIView, height: CGFloat?) {
        self.content = content
        self.preferredHeight = height
        super.init(frame: .zero)
        configureView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if previousWidth != bounds.width {
            previousWidth = bounds.width
            let collectionView = (content as? TimetableScrollableSheet)?.sheetScrollView as? UICollectionView
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }

    func sheetHeight(in context: KoinBottomSheetContext) -> CGFloat {
        if let preferredHeight { return min(preferredHeight, context.maximumHeight) }
        return (content as? TimetableSheetSizing)?.calculateSheetHeight(in: context) ?? context.maximumHeight / 2
    }

    func show(content: UIView, height: CGFloat?) {
        guard self.content !== content else {
            delegate?.invalidateHeight(animated: true)
            return
        }
        endEditing(true)
        self.content.removeFromSuperview()
        self.content = content
        preferredHeight = height
        previousWidth = 0
        setUpLayouts()
        setUpConstraints()
        delegate?.invalidateHeight(animated: true)
    }

    func removeContent() {
        content.removeFromSuperview()
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }

    private func setUpStyles() {
        backgroundColor = .systemBackground
    }

    private func setUpLayouts() {
        addSubview(content)
    }

    private func setUpConstraints() {
        content.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}


// 시간표와 목록이 진입 경로에 관계없이 같은 안내 및 로그인 이동을 사용한다.
extension UIViewController {
    func requireTimetableStudentAccess() -> Bool {
        let user = UserDataManager.shared
        guard !user.isStudent else { return true }
        guard presentedViewController == nil else { return false }
        let configuration: KoinModalConfiguration
        if user.isLoggedIn {
            configuration = .init(
                appearance: .new,
                content: .titles(
                    mainTitleText: "학생 전용 기능입니다.",
                    subTitleText: "해당 기능은 학생 인증을 완료한 사용자만 이용할 수 있어요."
                ),
                button: .singleButton(title: "확인")
            )
        } else {
            configuration = .init(
                appearance: .new,
                content: .titles(mainTitleText: "로그인이 필요한 기능입니다.", subTitleText: "로그인 하시겠어요?"),
                button: .buttons(
                    leftButtonTitle: "취소",
                    rightButtonTitle: "로그인하기",
                    rightButtonAction: { [weak self] in self?.navigateToLogin() }
                )
            )
        }
        present(KoinModalViewController(configuration: configuration), animated: true)
        return false
    }
}
