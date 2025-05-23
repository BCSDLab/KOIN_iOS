//
//  FrameListViewController.swift
//  koin
//
//  Created by 김나훈 on 11/21/24.
//

import Combine
import UIKit


final class FrameListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: TimetableViewModel
    private let inputSubject: PassthroughSubject<TimetableViewModel.NextInput, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let modifyFrameModalViewController: ModifyFrameModalViewController = ModifyFrameModalViewController(width: 327, height: 216)
    
    private let modifySemesterModalViewController: ModifySemesterModalViewController = ModifySemesterModalViewController(width: 327, height: 232)
    
    private let emptyFrameLabel = UILabel().then {
        $0.text = "우측 상단의 버튼으로 학기를 추가해\n시간표 기능을 사용해 보세요!"
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.textColor = UIColor.appColor(.neutral600)
        $0.font = UIFont.appFont(.pretendardMedium, size: 13)
    }
    
    private let deleteSemesterModalViewController = DeleteSemesterModalViewController().then { _ in
    }
    
    private let deleteFrameModalViewController = DeleteFrameModalViewController().then { _ in
    }
    
    // MARK: - Initialization
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude // 기본 여백 제거
    }
    init(viewModel: TimetableViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "시간표 목록"
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TimetableCell.self, forCellReuseIdentifier: "TimetableCell")
        inputSubject.send(.fetchFrameList)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0 // 섹션 헤더 상단 간격 제거
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        configureNavigationBar(style: .fill)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case .reloadData:
                self?.tableView.reloadData()
                self?.emptyFrameLabel.isHidden = !strongSelf.viewModel.frameData.isEmpty
            case .showToast(let message): self?.showToast(message: message, success: true)
            case .showToastWithId(let message, let id):
                self?.showToast(message: "\(message)\(message.hasFinalConsonant() ? "이" : "가") 삭제되었어요.", buttonTitle: "되돌리기", buttonId: id)
            }
        }.store(in: &subscriptions)
        
        toastButtonPublisher
            .sink { [weak self] id in
                self?.inputSubject.send(.rollbackFrame(id ?? 0))
            }
            .store(in: &subscriptions)
        
        modifyFrameModalViewController.deleteButtonPublisher.sink(receiveValue: { [weak self] frame in
            guard let self = self else { return }
            deleteFrameModalViewController.configure(frame: frame)
            present(deleteFrameModalViewController, animated: false)
        }).store(in: &subscriptions)
        
        modifyFrameModalViewController.saveButtonPublisher.sink(receiveValue: { [weak self] frame in
            self?.inputSubject.send(.modifyFrame(frame))
            
        }).store(in: &subscriptions)
        
        modifySemesterModalViewController.applyButtonPublisher.sink { [weak self] addedSemester, removedSemester in
            guard let self = self else { return }
            inputSubject.send(.modifySemester(addedSemester, []))
            if !removedSemester.isEmpty {
                deleteSemesterModalViewController.setSemesters(semesters: removedSemester)
                present(deleteSemesterModalViewController, animated: false)
            }
        }.store(in: &subscriptions)
        
        deleteSemesterModalViewController.deleteButtonPublisher.sink { [weak self] semesters in
            self?.inputSubject.send(.modifySemester([], semesters))
        }.store(in: &subscriptions)
        
        deleteFrameModalViewController.deleteButtonPublisher.sink { [weak self] frame in
            self?.inputSubject.send(.deleteFrame(frame))
        }.store(in: &subscriptions)
    }
    
}

extension FrameListViewController: TimetableCellDelegate {
    
    @objc private func modifySemesterButtonTapped() {
        
        modifySemesterModalViewController.configre(frameList: viewModel.frameData)
        self.present(modifySemesterModalViewController, animated: true)
        
    }
    
    @objc private func addTimetableTapped(_ sender: UIButton) {
        guard let headerView = sender.superview else { return } // 버튼의 부모 뷰 (headerView) 가져오기
        for subview in headerView.subviews {
            if let label = subview as? UILabel {
                if let semesterText = label.text {
                    inputSubject.send(.createFrame(semesterText.formatSemester()))
                }
                return
            }
        }
    }
    func settingButtonTapped(at indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        // 추가 동작 (예: 삭제 모달 띄우기)
        let timetable = viewModel.frameData[section].frame[row]
        modifyFrameModalViewController.configure(frame: viewModel.frameData[section].frame[row])
        self.present(modifyFrameModalViewController, animated: true)
        
        
    }
    
}
extension FrameListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀 탭 이벤트 처리
        let section = indexPath.section
        let row = indexPath.row
        let timetable = viewModel.frameData[section].frame[row]
        viewModel.selectedSemester = viewModel.frameData[section].semester
        viewModel.selectedFrameId = viewModel.frameData[section].frame[row].id
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55 // 원하는 셀 높이 설정
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60 // 원하는 높이 설정
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.frameData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.frameData[section].frame.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimetableCell", for: indexPath) as? TimetableCell else {
            fatalError("TimetableCell not found")
        }
        let timetable = viewModel.frameData[indexPath.section].frame[indexPath.row]
        cell.configure(with: timetable, at: indexPath)
        cell.delegate = self // Delegate 연결
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = viewModel.frameData[section].semester.reverseFormatSemester()
        label.font = UIFont.appFont(.pretendardBold, size: 20)
        
        let addButton = UIButton()
        addButton.setImage(UIImage.appImage(asset: .plusBold), for: .normal)
        addButton.tag = section // 섹션 정보를 태그로 저장
        addButton.addTarget(self, action: #selector(addTimetableTapped(_:)), for: .touchUpInside)
        let view1 = UIView()
        let view2 = UIView()
        view1.backgroundColor = UIColor.appColor(.neutral300)
        view2.backgroundColor = UIColor.appColor(.neutral300)
        headerView.addSubview(label)
        headerView.addSubview(addButton)
        headerView.addSubview(view1)
        headerView.addSubview(view2)
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(headerView.snp.leading).offset(24)
            make.centerY.equalTo(headerView.snp.centerY)
        }
        addButton.snp.makeConstraints { make in
            make.trailing.equalTo(headerView.snp.trailing).offset(-32)
            make.centerY.equalTo(headerView.snp.centerY)
            make.width.height.equalTo(24)
        }
        view1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(headerView.snp.leading).offset(15)
            make.trailing.equalTo(headerView.snp.trailing)
            make.height.equalTo(1)
        }
        view2.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalTo(headerView.snp.leading).offset(15)
            make.trailing.equalTo(headerView.snp.trailing)
            make.height.equalTo(1)
        }
        
        return headerView
    }
    
}

extension FrameListViewController {
    
}


extension FrameListViewController {
    
    private func setUpLayOuts() {
        [tableView, emptyFrameLabel].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        emptyFrameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.centerX.equalTo(view.snp.centerX)
        }
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    private func setUpNavigationBar() {
        let modifyTimetableButton = UIBarButtonItem(image: UIImage.appImage(asset: .write), style: .plain, target: self, action: #selector(modifySemesterButtonTapped))
        navigationItem.rightBarButtonItem = modifyTimetableButton
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        setUpNavigationBar()
        self.view.backgroundColor = .systemBackground
    }
}
