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
    
    private let containerView = UIView().then { _ in
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
        print(KeyChainWorker.shared.read(key: .access))
        semesterSelectButton.addTarget(self, action: #selector(modifySemesterButtonTapped), for: .touchUpInside)
        downloadImageButton.addTarget(self, action: #selector(downloadTimetableAsImage), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
            self.toggleCollectionView(collectionView: self.addClassCollectionView, animate: true)
        }.store(in: &subscriptions)
        
        addClassCollectionView.addDirectButtonPublisher.sink { [weak self] in
            self?.addClassCollectionView.isHidden = true
            self?.addDirectCollectionView.isHidden = false
        }.store(in: &subscriptions)
        
        addClassCollectionView.modifyClassButtonPublisher.sink { [weak self] lecture in
            self?.inputSubject.send(.modifyLecture(lecture.0, lecture.1))
        }.store(in: &subscriptions)
        
        
        // MARK: DIRECT
        
        addDirectCollectionView.addClassButtonPublisher.sink { [weak self] in
            self?.addClassCollectionView.isHidden = false
            self?.addDirectCollectionView.isHidden = true
        }.store(in: &subscriptions)
        
        addDirectCollectionView.addClassButtonPublisher.sink { [weak self] lecture in
            //  self?.toggleCollectionView()
        }.store(in: &subscriptions)
        
        addDirectCollectionView.completeButtonPublisher.sink { [weak self] item in
            guard let self = self else { return }
            
            self.toggleCollectionView(collectionView: self.addDirectCollectionView, animate: true)
            self.inputSubject.send(.postCustomLecture(item.0, item.1))
        }.store(in: &subscriptions)
        
        
        // MARK: ETC
        
        deleteLectureView.completeButtonPublisher.sink { [weak self] in
            self?.deleteLectureView.isHidden = true
            
        }.store(in: &subscriptions)
        
        deleteLectureView.deleteButtonPublisher.sink { [weak self] lecture in
            self?.deleteLectureView.isHidden = true
            self?.inputSubject.send(._deleteLecture(lecture))
            
        }.store(in: &subscriptions)
    }
    
}

extension TimetableViewController {
    private func setUpCollectionViewHeight(_ lectureList: [LectureData]) {
        // 강의 시간에서 마지막 2자리 추출
        let lastTwoDigits = lectureList.flatMap { $0.classTime.map { $0 % 100 } }
        
        // 마지막 2자리 숫자의 최댓값 구하기
        guard let maxLastTwoDigits = lastTwoDigits.max() else { return }
        
        // 마지막 2자리 최댓값을 2로 나눈 값 계산
        let dividedValue = maxLastTwoDigits / 2
        
        print(maxLastTwoDigits)
    
        // 17과 (9 + dividedValue) 중 최댓값 계산
        let upperLimit = max(17, 9 + dividedValue)
        
        // 9부터 upperLimit까지의 배열 생성
        let resultArray = Array(9...upperLimit)
        timetableCollectionView.updateLecture(lectureTime: resultArray)
        timetableCollectionView.snp.updateConstraints { make in
            make.height.equalTo(timetableCollectionView.calculateDynamicHeight())
        }
//        containerView.snp.updateConstraints { make in
//            make.height.equalTo(timetableCollectionView.calculateDynamicHeight())
//        }
    }

    @objc private func modifySemesterButtonTapped() {
        navigationController?.pushViewController(FrameListViewController(viewModel: viewModel), animated: true)
    }
    private func updateTimetable(lectureData: [LectureData]) {
        // 현재 남아있는 LectureView들의 `info`를 비교하기 위해 사용
        let existingLectureViews = containerView.subviews.compactMap { $0 as? LectureView }
        
        // 새로 추가된 LectureData와 기존 LectureView를 비교
        let existingLectureInfos = Set(existingLectureViews.map { $0.info })
        let newLectureInfos = Set(lectureData)
        
        // 추가된 강의 데이터 (새로운 데이터)
        let addedLectures = newLectureInfos.subtracting(existingLectureInfos)
        // 제거된 강의 데이터 (기존에 있던 데이터 중 새로 들어온 데이터에 없는 경우)
        let removedLectureViews = existingLectureViews.filter { !newLectureInfos.contains($0.info) }
        removedLectureViews.forEach { $0.removeFromSuperview() }
        
        // 이미 사용된 body 색상을 추적
        var usedColors: Set<UIColor> = Set(existingLectureViews.compactMap { $0.backgroundColor })
        
        // 강의 ID와 할당된 색상 쌍을 저장
        var lectureColorMap: [Int: (UIColor, UIColor)] = [:]
        
        for lectureView in existingLectureViews {
            let lecture = lectureView.info // `info`가 Optional이 아니므로 바로 사용 가능
            if let bodyColor = lectureView.backgroundColor, let headerColor = lectureView.separateView.backgroundColor {
                lectureColorMap[lecture.id] = (bodyColor, headerColor)
            }
        }


        
        // 사용 가능한 색상 쌍에서 이미 사용된 것을 제외
        var unusedColorPairs = timetableColors.compactMap { colorPair -> (UIColor, UIColor)? in
            let bodyColor = UIColor.timetableColor(_name: colorPair.0)
            let headerColor = UIColor.timetableColor(_name: colorPair.1)
            return usedColors.contains(bodyColor) ? nil : (bodyColor, headerColor)
        }
        
        // 새로운 강의 데이터를 추가
        for lecture in addedLectures {
            let groupedByDay = Dictionary(grouping: lecture.classTime) { $0 / 100 } // 요일별로 그룹화
            
            for (day, times) in groupedByDay {
                let separatedTimes = times.splitIntoContinuousRanges() // 연속된 시간을 나눔
                
                for range in separatedTimes {
                    if let firstTime = range.first {
                        let width = Int(containerView.frame.width / 5) + 1 // 5열 기준
                        let height = 35
                        
                        // 색상 쌍을 가져옴 (기존 강의 색상이 있으면 동일한 색 사용)
                        let colorPair: (UIColor, UIColor)
                        if let existingColor = lectureColorMap[lecture.id] {
                            colorPair = existingColor
                        } else {
                            colorPair = unusedColorPairs.isEmpty ? (UIColor.appColor(.neutral300), UIColor.appColor(.neutral800)) : unusedColorPairs.removeFirst()
                            lectureColorMap[lecture.id] = colorPair // 새 강의에 색상 맵핑
                        }
                        
                        let bodyColor = colorPair.0
                        let headerColor = colorPair.1
                        
                        // LectureView 생성
                        let lectureView = LectureView(info: lecture, color: bodyColor)
                        lectureView.separateView.backgroundColor = headerColor // separateView는 headerColor 사용
                        
                        // 나머지 3개의 UI 요소에 bodyColor 적용
                        lectureView.backgroundColor = bodyColor
                        lectureView.lectureNameLabel.backgroundColor = bodyColor
                        lectureView.professorNameLabel.backgroundColor = bodyColor
                        
                        // GestureRecognizer 추가
                        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLectureTap(_:)))
                        lectureView.addGestureRecognizer(tapGesture)
                        lectureView.isUserInteractionEnabled = true
                        
                        containerView.addSubview(lectureView)
                        lectureView.snp.makeConstraints { make in
                            make.width.equalTo(width)
                            make.height.equalTo(height * range.count) // 강의 시간의 개수만큼 높이 설정
                            make.top.equalTo(containerView.snp.top).offset(height * (firstTime % 100))
                            make.leading.equalTo(containerView.snp.leading).offset(width * day)
                        }
                        
                        // 새로 추가된 body 색상을 사용된 색상으로 추가
                        usedColors.insert(bodyColor)
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
            semesterSelectButton.setTitle("\(semester.reverseFormatSemester())", for: .normal)
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
        // 각각의 뷰를 캡처
        let timetableImage = captureViewAsImage(view: timetableCollectionView)
        let containerImage = captureViewAsImage(view: containerView)

        // 두 이미지를 같은 영역에 합쳐서 하나의 이미지 생성
        let combinedImage = combineImagesInSameArea(topImage: containerImage, bottomImage: timetableImage)

        // 이미지를 앨범에 저장
        UIImageWriteToSavedPhotosAlbum(combinedImage, self, #selector(saveImageCallback(_:didFinishSavingWithError:contextInfo:)), nil)
    }


    // 특정 뷰를 이미지로 캡처
    private func captureViewAsImage(view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { context in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }

    // 두 이미지를 세로로 합치기
    private func combineImagesInSameArea(topImage: UIImage, bottomImage: UIImage) -> UIImage {
        let size = CGSize(width: max(topImage.size.width, bottomImage.size.width),
                          height: max(topImage.size.height, bottomImage.size.height))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // 아래 이미지를 먼저 그리기
            bottomImage.draw(in: CGRect(origin: .zero, size: size))
            // 위 이미지를 동일한 위치에 겹쳐서 그리기
            topImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }


   
    @objc private func saveImageCallback(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // 저장 실패 시 알림
            showAlert(title: "저장 실패", message: error.localizedDescription)
        } else {
            // 저장 성공 시 알림
            showAlert(title: "저장 성공", message: "이미지가 앨범에 저장되었습니다.")
        }
    }

    // 알림창을 표시하는 메서드
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default) { _ in
            // 확인 버튼을 누르면 알림창 닫힘
        }
        alert.addAction(action)
        // 현재 화면에 알림창 표시
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
            topViewController.present(alert, animated: true, completion: nil)
        }
    }


}

extension TimetableViewController {
    
    private func setUpLayOuts() {
        [scrollView, semesterSelectButton, downloadImageButton, addClassCollectionView, addDirectCollectionView, deleteLectureView].forEach {
            view.addSubview($0)
        }
        [timetableCollectionView, containerView, emptyView].forEach {
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
            make.height.equalTo(100)
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
