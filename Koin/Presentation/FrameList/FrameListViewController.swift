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
    private let tableView = UITableView()
    
    // MARK: - Initialization
    
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
        setUpTableView()
        inputSubject.send(.fetchFrameList)
    }
    
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            switch output {
            case .reloadData: self?.tableView.reloadData()
                
            }
        }.store(in: &subscriptions)
        
        
    }
    @objc private func addSemesterTapped() {
        //            let newSemester = Semester(id: UUID(), name: "새 학기", timetables: [])
        //            semesters.append(newSemester)
        //            tableView.reloadData()
    }
}
extension FrameListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55 // 원하는 셀 높이 설정
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60 // 원하는 높이 설정
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.frameData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.frameData[section].semester.reverseFormatSemester() // 섹션 헤더에 학기 이름 표시
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.frameData[section].frame.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimetableCell", for: indexPath) as? TimetableCell else {
            fatalError("TimetableCell not found")
        }
        let timetable = viewModel.frameData[indexPath.section].frame[indexPath.row]
        cell.configure(with: timetable)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = viewModel.frameData[section].semester
        label.font = UIFont.appFont(.pretendardBold, size: 20)
        
        let addButton = UIButton()
        addButton.setImage(UIImage.appImage(asset: .plusBold), for: .normal)
        addButton.tag = section // 섹션 정보를 태그로 저장
        addButton.addTarget(self, action: #selector(addTimetableTapped(_:)), for: .touchUpInside)
        
        headerView.addSubview(label)
        headerView.addSubview(addButton)
        
        label.snp.makeConstraints { make in
            make.leading.equalTo(headerView.snp.leading).offset(24)
            make.centerY.equalTo(headerView.snp.centerY)
        }
        addButton.snp.makeConstraints { make in
            make.trailing.equalTo(headerView.snp.trailing).offset(-32)
            make.centerY.equalTo(headerView.snp.centerY)
            make.width.height.equalTo(24)
        }
        
        return headerView
    }
}

extension FrameListViewController {
    
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
}


extension FrameListViewController {
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TimetableCell.self, forCellReuseIdentifier: "TimetableCell")
    }
    
    @objc private func modifySemesterButtonTapped() {
        
    }
}

extension FrameListViewController {
    
    private func setUpLayOuts() {
        [tableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        
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
