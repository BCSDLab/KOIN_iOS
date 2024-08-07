////
////  TimeTableViewController.swift
////  koin
////
////  Created by 김나훈 on 3/29/24.
////
//
//
//import Combine
//import SnapKit
//import UIKit
//
//final class TimetableViewController: UIViewController {
//    
//    // MARK: - Properties
//    
//    private let viewModel: TimetableViewModel
//    private let inputSubject: PassthroughSubject<TimetableViewModel.Input, Never> = .init()
//    private var subscriptions: Set<AnyCancellable> = []
//    
//    // MARK: - UI Components
//    
//    private let scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        return scrollView
//    }()
//    private let semesterSelectButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitleColor(UIColor.appColor(.black), for:.normal)
//        button.layer.cornerRadius = 5
//        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
//        button.layer.borderWidth = 1.0
//        button.layer.borderColor = UIColor.appColor(.borderGray).cgColor
//        return button
//    }()
//
//
//    private let imageSaveButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("이미지로 저장하기", for: .normal)
//        button.setTitleColor(UIColor.appColor(.blue), for:.normal)
//        button.layer.cornerRadius = 5
//        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
//        button.layer.borderWidth = 1.0
//        button.layer.borderColor = UIColor.appColor(.blue).cgColor
//        return button
//    }()
//    
//    private let timetableCollectionView: TimetableCollectionView = {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.minimumLineSpacing = 0
//        flowLayout.scrollDirection = .vertical
//        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 30)
//        let collectionView = TimetableCollectionView(frame: .zero, collectionViewLayout: flowLayout)
//        collectionView.isScrollEnabled = false
//        return collectionView
//    }()
//    
//    private let grayView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.appColor(.simpleGray)
//        return view
//    }()
//    
//    private var weekDayLabel: [UILabel] = {
//        var labelsArray = [UILabel]()
//        let labelText: [String] = ["월", "화", "수", "목", "금"]
//        for i in 0..<5 {
//            let label = UILabel()
//            label.text = labelText[i]
//            label.textAlignment = .center
//            label.font = UIFont.appFont(.pretendardRegular, size: 12)
//            label.textColor = UIColor.appColor(.textGray)
//            label.backgroundColor = UIColor.appColor(.simpleGray)
//            labelsArray.append(label)
//        }
//        return labelsArray
//    }()
//    
//    private lazy var stackView: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .horizontal
//        stack.distribution = .fillEqually
//        stack.alignment = .fill
//        stack.spacing = 0
//        return stack
//    }()
//    
//    private let semesterSelectTableView: SemesterSelectTableView = {
//        let tableView = SemesterSelectTableView()
//        tableView.isHidden = true
//        return tableView
//    }()
//    
//    private let addClassView: AddClassView = {
//        let view = AddClassView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.isHidden = true
//        return view
//    }()
//    
//    
//    // MARK: - Initialization
//    
//    init(viewModel: TimetableViewModel) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: - Life Cycles
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        bind()
//        configureView()
//        inputSubject.send(.getSemesterList)
//        semesterSelectButton.addTarget(self, action: #selector(toggleSemesterSelectTableView), for: .touchUpInside)
//        setupNavigationBar()
//        hideKeyboardWhenTappedAround()
//        addClassView.searchTextField.delegate = self
//        imageSaveButton.addTarget(self, action: #selector(saveToImage), for: .touchUpInside)
//        print(KeyChainWorker.shared.read(key: .access))
//        print(KeyChainWorker.shared.read(key: .refresh))
//    }
//    
//    // MARK: - Bind
//    
//    private func bind() {
//        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
//        
//        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
//            switch output {
//            case let .initSemesterList(list):
//                self?.initSemesterList(list)
//            case let .updateTimetables(table, semester):
//                self?.updateTimetables(table, semester)
//            case let .updateFilteredLecture(lectureList):
//                self?.addClassView.updateCollectionViewData(lectureList)
//            case let .deleteTimetable(id):
//                self?.timetableCollectionView.removeCellsInfoById(id)
//            case .requestLogInAgain:
//                self?.requestLogInAgain()
//            }
//        }.store(in: &subscriptions)
//        
//        semesterSelectTableView.didSelectSemester = { [weak self] semester in
//            self?.semesterSelectTableView.isHidden = true
//            self?.inputSubject.send(.changeSemester(semester))
//        }
//        
//        addClassView.searchTextPublisher.sink { [weak self] text in
//            self?.inputSubject.send(.filterClass(text))
//        }.store(in: &subscriptions)
//        
//        addClassView.addClassCollectionView.addButtonPublisher
//            .sink { [weak self] lecture in
//                guard let self = self else { return }
//                guard let title = self.semesterSelectButton.title(for: .normal) else { return }
//                let filteredNumbers = title.filter { $0.isNumber }
//                if self.timetableCollectionView.canAddLecture(at: lecture.classTime) {
//                    self.inputSubject.send(.addLecture(lecture, filteredNumbers))
//                }
//                else {
//                    self.showImpossibleAlert()
//                }
//             
//            }
//            .store(in: &subscriptions)
//        
//        timetableCollectionView.cellTapPublisher.sink { [weak self] cellId in
//            self?.showDeleteAlert(cellId: cellId) { shouldDelete in
//                if shouldDelete {
//                    self?.inputSubject.send(.deleteTimetable(cellId))
//                }
//            }
//        }.store(in: &subscriptions)
//        
//        semesterSelectTableView.didTapCompleteButton.sink { [weak self] () in
//            self?.semesterSelectTableView.isHidden = true
//        }.store(in: &subscriptions)
//        
//        addClassView.didTapCompleteButton.sink { [weak self] () in
//            self?.addClassView.isHidden = true
//        }.store(in: &subscriptions)
//    }
//}
//
//extension TimetableViewController {
//    
//    private func showImpossibleAlert() {
//        let alertController = UIAlertController(title: "실패", message: "해당 시간대에 이미 다른 시간표가 존재합니다.", preferredStyle: .alert)
//        
//        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
//           
//        }
//        
//        alertController.addAction(confirmAction)
//        
//        present(alertController, animated: true, completion: nil)
//    }
//    
//    @objc private func saveToImage() {
//        let alertController = UIAlertController(title: "구현 중입니다.", message: "커밍 쑨", preferredStyle: .alert)
//        
//        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
//           
//        }
//        
//        alertController.addAction(confirmAction)
//        
//        present(alertController, animated: true, completion: nil)
//    }
//    
//    func requestLogInAgain() {
//        let alertController = UIAlertController(title: "세션 만료", message: "세션이 만료되었습니다. 다시 로그인해주세요.", preferredStyle: .alert)
//        
//        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
//            self?.navigationController?.popViewController(animated: true)
//        }
//        
//        alertController.addAction(confirmAction)
//        
//        present(alertController, animated: true, completion: nil)
//    }
//    
//    private func showDeleteAlert(cellId: Int, completion: @escaping (Bool) -> Void)  {
//        let alert = UIAlertController(title: "수업 삭제", message: "해당 수업을 삭제하시겠습니까?", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { _ in
//            completion(true)
//        }))
//        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { _ in
//            completion(false)
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
//    private func setupNavigationBar() {
//        let saveImageButton = UIBarButtonItem(image: UIImage.appImage(asset: .write), style: .plain, target: self, action: #selector(writeButtonTapped))
//        navigationItem.rightBarButtonItem = saveImageButton
//    }
//    
//    @objc private func writeButtonTapped() {
//        semesterSelectTableView.isHidden = true
//        inputSubject.send(.filterClass(nil))
//        addClassView.isHidden.toggle()
//    }
//    
//    private func updateTimetables(_ table: TimetablesDTO, _ semester: SemesterDTO?) {
//        semesterSelectButton.setTitle(semester?.formattedSemester, for: .normal)
//        timetableCollectionView.updatetimetables(table)
//    }
//    
//    private func initSemesterList(_ list: [SemesterDTO]) {
//        semesterSelectTableView.semesters = list
//        semesterSelectTableView.reloadData()
//        semesterSelectButton.setTitle(list.first?.formattedSemester, for: .normal)
//    }
//    
//    @objc func toggleSemesterSelectTableView() {
//        addClassView.isHidden = true
//        semesterSelectTableView.isHidden.toggle()
//    }
//}
//
//
//extension TimetableViewController {
//    private func setUpLayOuts() {
//        view.addSubview(scrollView)
//        view.addSubview(semesterSelectTableView)
//        view.addSubview(addClassView)
//        [semesterSelectButton, imageSaveButton, timetableCollectionView, stackView, grayView].forEach {
//            scrollView.addSubview($0)
//        }
//        weekDayLabel.forEach { label in
//            stackView.addArrangedSubview(label)
//        }
//    }
//    
//    private func setUpConstraints() {
//        scrollView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
//        
//        semesterSelectButton.snp.makeConstraints { make in
//            make.top.equalTo(scrollView.snp.top).offset(Padding.viewSide)
//            make.leading.equalTo(scrollView.snp.leading).offset(20)
//            make.width.equalTo(Metrics.buttonWidth)
//            make.height.equalTo(Metrics.buttonHeight)
//        }
//        
//        imageSaveButton.snp.makeConstraints { make in
//            make.top.equalTo(scrollView.snp.top).offset(Padding.viewSide)
//            make.trailing.equalTo(scrollView.snp.trailing).offset(-20)
//            make.width.equalTo(Metrics.buttonWidth)
//            make.height.equalTo(Metrics.buttonHeight)
//        }
//        
//        grayView.snp.makeConstraints { make in
//            make.leading.equalTo(scrollView.snp.leading)
//            make.trailing.equalTo(stackView.snp.leading)
//            make.height.equalTo(30)
//            make.top.equalTo(semesterSelectButton.snp.bottom).offset(20)
//        }
//        
//        stackView.snp.makeConstraints { make in
//            make.leading.equalTo(scrollView.snp.leading).offset(80)
//            make.trailing.equalTo(scrollView.snp.trailing)
//            make.height.equalTo(30)
//            make.top.equalTo(semesterSelectButton.snp.bottom).offset(20)
//        }
//        
//        timetableCollectionView.snp.makeConstraints { make in
//            make.top.equalTo(stackView.snp.bottom)
//            make.leading.trailing.equalTo(scrollView)
//            make.bottom.equalTo(scrollView.snp.bottom)
//            make.width.equalTo(view.snp.width)
//        }
//        timetableCollectionView.snp.makeConstraints { make in
//            make.height.equalTo(timetableCollectionView.calculateDynamicHeight())
//        }
//        
//        semesterSelectTableView.snp.makeConstraints { make in
//            make.height.equalTo(view.snp.height).multipliedBy(0.5)
//            make.leading.equalTo(scrollView.snp.leading)
//            make.trailing.equalTo(scrollView.snp.trailing)
//            make.bottom.equalTo(view.snp.bottom)
//        }
//        
//        addClassView.snp.makeConstraints { make in
//            make.height.equalTo(view.snp.height).multipliedBy(0.5)
//            make.leading.equalTo(scrollView.snp.leading)
//            make.trailing.equalTo(scrollView.snp.trailing)
//            make.bottom.equalTo(view.snp.bottom)
//        }
//    }
//    
//    private func configureView() {
//        setUpLayOuts()
//        setUpConstraints()
//        self.view.backgroundColor = .systemBackground
//    }
//}
//
//extension TimetableViewController {
//    enum Metrics {
//        static let buttonWidth: CGFloat = ( UIScreen.main.bounds.width / 2) - 40
//        static let buttonHeight: CGFloat = 50
//    }
//    enum Padding {
//        static let viewSide: CGFloat = 30
//    }
//}
//
