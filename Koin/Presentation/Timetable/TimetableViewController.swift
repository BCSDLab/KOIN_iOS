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
        timetableCollectionView.snp.updateConstraints { make in
            make.height.equalTo(timetableCollectionView.calculateDynamicHeight())
        }
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
            self?.inputSubject.send(.modifyLecture(lecture, false))
            
        }.store(in: &subscriptions)
    }
    
}

extension TimetableViewController {
    @objc private func modifySemesterButtonTapped() {
        navigationController?.pushViewController(FrameListViewController(viewModel: viewModel), animated: true)
    }
    
    private func updateTimetable(lectureData: [LectureData]) {
        containerView.subviews.forEach { $0.removeFromSuperview() }
        
        for lecture in lectureData {
            let groupedByDay = Dictionary(grouping: lecture.classTime) { $0 / 100 }
            
            for (day, times) in groupedByDay {
                let separatedTimes = splitIntoContinuousRanges(times)
                
                for range in separatedTimes {
                    if let firstTime = range.first {
                        let width = Int(containerView.frame.width / 5) + 1// 5열 기준
                        let height = 35
                        
                        // LectureView 생성
                        let lectureView = LectureView(info: lecture, color: UIColor.appColor(.neutral300))
                        
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


    // 이미지 저장 콜백
    @objc private func saveImageCallback(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("이미지 저장 실패: \(error.localizedDescription)")
        } else {
            print("이미지 저장 성공!")
        }
    }

}

extension TimetableViewController {
    
    private func setUpLayOuts() {
        [semesterSelectButton, downloadImageButton, timetableCollectionView, containerView, addClassCollectionView, addDirectCollectionView, deleteLectureView].forEach {
            view.addSubview($0)
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
        timetableCollectionView.snp.makeConstraints { make in
            make.top.equalTo(semesterSelectButton.snp.bottom).offset(14)
            make.leading.equalTo(view.snp.leading).offset(24)
            make.trailing.equalTo(view.snp.trailing).offset(-24)
            make.height.equalTo(100)
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
