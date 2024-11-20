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
        print(KeyChainWorker.shared.read(key: .access))
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
            }
        }.store(in: &subscriptions)
        
        // MARK: CLASS
        
        addClassCollectionView.completeButtonPublisher.sink { [weak self] in
            guard let self = self else { return }
            self.toggleCollectionView(collectionView: self.addClassCollectionView, animate: true)
        }.store(in: &subscriptions)
        
        addClassCollectionView.addDirectButtonPublisher.sink { [weak self] in
            self?.addClassCollectionView.isHidden.toggle()
            self?.addDirectCollectionView.isHidden.toggle()
        }.store(in: &subscriptions)
        
        addClassCollectionView.modifyClassButtonPublisher.sink { [weak self] lecture in
            print(lecture)
        }.store(in: &subscriptions)
        
        
        // MARK: DIRECT
        
        addDirectCollectionView.addClassButtonPublisher.sink { [weak self] in
            self?.addClassCollectionView.isHidden.toggle()
            self?.addDirectCollectionView.isHidden.toggle()
        }.store(in: &subscriptions)
        
        addDirectCollectionView.addClassButtonPublisher.sink { [weak self] in
          //  self?.toggleCollectionView()
        }.store(in: &subscriptions)
    }
    
}

extension TimetableViewController {
    
    private func updateSemesterButtonText(semester: String, frameName: String?) {
        if let frameName = frameName {
            semesterSelectButton.setTitle("\(semester) / \(frameName)", for: .normal)
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
        
        
        if animate {
            if collectionView.isHidden {
                collectionView.transform = CGAffineTransform(translationX: 0, y: addClassCollectionView.frame.height)
                collectionView.isHidden = false
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    collectionView.transform = .identity
                }
            } else {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    collectionView.transform = CGAffineTransform(translationX: 0, y: collectionView.frame.height)
                }) { _ in
                    collectionView.isHidden = true
                }
            }
        } else {
           
        }
        
        
        
    }
}

extension TimetableViewController {
    
    private func setUpLayOuts() {
        [semesterSelectButton, downloadImageButton, timetableCollectionView, addClassCollectionView, addDirectCollectionView].forEach {
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
            make.bottom.equalTo(view.snp.bottom)
        }
        addClassCollectionView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.centerY)
            make.leading.trailing.bottom.equalToSuperview()
        }
        addDirectCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(addClassCollectionView)
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
