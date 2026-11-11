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
    // 화면 전체가 스크롤되고, 테두리 안 목록은 내용 높이만큼 펼쳐 스크롤하지 않는다.
    private let scrollView = UIScrollView()
    private let listContainerView = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let accessNoticeLabel = UILabel()
    private let emptyStateView = UIStackView()
    private let emptyImageView = UIImageView(image: .appImage(asset: .sleepBcsdSymbol))
    private let emptyFrameLabel = UILabel()

    private var displayedFrames: [FrameData] {
        viewModel.canUseStudentFeatures ? viewModel.frameData : viewModel.previewFrameData
    }

    private var listContentHeight: CGFloat {
        let sections = displayedFrames
        let rowCount = sections.reduce(0) { $0 + $1.frame.count }
        let itemCount = sections.count + rowCount
        guard itemCount > 0 else { return 0 }
        // 48pt 내용 행 + 항목 사이 2pt, 첫/마지막 안쪽 여백 4pt씩.
        let rowsHeight = CGFloat(itemCount) * 48
        let spacingHeight = CGFloat(max(0, itemCount - 1)) * 2
        return rowsHeight + spacingHeight + 8
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TimetableCell.self, forCellReuseIdentifier: "TimetableCell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0 // 섹션 헤더 상단 간격 제거
        }
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(style: .empty)
        inputSubject.send(.fetchFrameList)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let self else { return }
            switch output {
            case .reloadData:
                self.updateAccessUI()
            case let .showToast(message, intent):
                self.showToastMessage(message: message, intent: intent)
            case let .showSemesterModal(semesters):
                self.presentModifySemesterModal(semesters: semesters)
            }
        }.store(in: &subscriptions)
        
        viewModel.$canUseStudentFeatures.receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.updateAccessUI()
        }.store(in: &subscriptions)
        viewModel.$hasLoadedFrames.removeDuplicates().receive(on: DispatchQueue.main).sink { [weak self] _ in
            self?.updateAccessUI()
        }.store(in: &subscriptions)

    }
    
}

extension FrameListViewController: TimetableCellDelegate {
    
    @objc private func modifySemesterButtonTapped() {
        guard requireStudentAccess() else { return }
        // 학기 목록을 받은 뒤 showSemesterModal로 모달을 띄운다.
        inputSubject.send(.fetchSemesters)
    }

    private func presentModifySemesterModal(semesters: [String]) {
        guard presentedViewController == nil else { return }
        let modifySemesterModalViewController = ModifySemesterModalViewController(
            semesters: semesters,
            onApplyButtonTapped: { [weak self] addedSemesters, removedSemesters in
                self?.applySemesterChanges(addedSemesters: addedSemesters, removedSemesters: removedSemesters)
            }
        )
        modifySemesterModalViewController.configure(frameList: viewModel.frameData)
        present(modifySemesterModalViewController, animated: true)
    }
    
    @objc private func addTimetableTapped(_ sender: UIButton) {
        guard requireStudentAccess() else { return }
        guard displayedFrames.indices.contains(sender.tag) else { return }
        inputSubject.send(.createFrame(displayedFrames[sender.tag].semester))
    }
    func settingButtonTapped(at indexPath: IndexPath) {
        guard requireStudentAccess() else { return }
        let section = indexPath.section
        let row = indexPath.row
        
        // 추가 동작 (예: 삭제 모달 띄우기)
        let modifyFrameModalViewController = ModifyFrameModalViewController(
            onDeleteButtonTapped: { [weak self] frame in
                self?.presentDeleteFrameModal(frame: frame)
            },
            onSaveButtonTapped: { [weak self] frame in
                self?.inputSubject.send(.modifyFrame(frame))
            }
        )
        modifyFrameModalViewController.configure(frame: viewModel.frameData[section].frame[row])
        present(modifyFrameModalViewController, animated: true)
    }

    private func applySemesterChanges(addedSemesters: [String], removedSemesters: [String]) {
        guard requireStudentAccess() else { return }
        if !addedSemesters.isEmpty {
            logSemesterChange(action: "추가", semesters: addedSemesters)
        }
        inputSubject.send(.modifySemester(addedSemesters, []))
        guard !removedSemesters.isEmpty else { return }

        let deleteSemesterModalViewController = DeleteSemesterModalViewController(semesters: removedSemesters) { [weak self] semesters in
            self?.logSemesterChange(action: "삭제", semesters: semesters)
            self?.inputSubject.send(.modifySemester([], semesters))
        }
        present(deleteSemesterModalViewController, animated: true)
    }

    /// 명세 2-13·2-14 value: {추가 또는 삭제}_{연도}_{학기}, 여러 학기는 쉼표로 잇는다 (예: 추가_2026_겨울학기).
    private func logSemesterChange(action: String, semesters: [String]) {
        let value = semesters
            .map { "\(action)_\($0.prefix(4))_\(ModifySemesterModalViewController.title(of: $0))" }
            .joined(separator: ",")
        inputSubject.send(.logEvent(EventParameter.EventLabel.Timetable.timetableSemesterManageEditApplyClick, value))
    }

    private func presentDeleteFrameModal(frame: FrameDto) {
        guard requireStudentAccess() else { return }
        let deleteFrameModalViewController = DeleteFrameModalViewController(frame: frame) { [weak self] frame in
            self?.inputSubject.send(.deleteFrame(frame))
        }
        present(deleteFrameModalViewController, animated: true)
    }
}
extension FrameListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard requireStudentAccess() else { return }
        // 셀 탭 이벤트 처리
        let section = indexPath.section
        let row = indexPath.row
        let isNewSelection = viewModel.selectedFrameId != viewModel.frameData[section].frame[row].id
        viewModel.selectedSemester = viewModel.frameData[section].semester
        viewModel.selectedFrameId = viewModel.frameData[section].frame[row].id
        if isNewSelection {
            // 명세 2-27 value: {연도}_{학기}_{시간표명} (예: 2026_2학기_기본 시간표)
            let semesterValue = viewModel.frameData[section].semester.reverseFormatSemester().replacingOccurrences(of: "년 ", with: "_")
            inputSubject.send(.logEvent(EventParameter.EventLabel.Timetable.timetableListTimetableListSelect, "\(semesterValue)_\(viewModel.frameData[section].frame[row].timetableName)"))
        }
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isLast = indexPath.section == displayedFrames.count - 1 && indexPath.row == displayedFrames[indexPath.section].frame.count - 1
        return isLast ? 52 : 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let isLastItem = section == displayedFrames.count - 1 && displayedFrames[section].frame.isEmpty
        return CGFloat(48 + (section == 0 ? 4 : 0) + (isLastItem ? 4 : 2))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return displayedFrames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedFrames[section].frame.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimetableCell", for: indexPath) as? TimetableCell else {
            fatalError("TimetableCell not found")
        }
        let timetable = displayedFrames[indexPath.section].frame[indexPath.row]
        cell.configure(with: timetable, at: indexPath, canEdit: viewModel.canUseStudentFeatures)
        cell.delegate = self // Delegate 연결
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        FrameListSectionHeaderView(semester: displayedFrames[section].semester, section: section) { [weak self] button in
            self?.addTimetableTapped(button)
        }
    }

}

extension FrameListViewController {
    private func requireStudentAccess() -> Bool {
        requireTimetableStudentAccess()
    }

    @objc private func accessNoticeTapped() {
        _ = requireStudentAccess()
    }

    private func updateAccessUI() {
        let isPreview = !viewModel.canUseStudentFeatures
        accessNoticeLabel.isHidden = !isPreview
        let hasFrames = viewModel.frameData.contains { !$0.frame.isEmpty }
        emptyStateView.isHidden = isPreview || !viewModel.hasLoadedFrames || hasFrames
        listContainerView.isHidden = !emptyStateView.isHidden
        listContainerView.snp.remakeConstraints {
            if isPreview {
                $0.top.equalTo(accessNoticeLabel.snp.bottom).offset(11)
            } else {
                $0.top.equalTo(scrollView.contentLayoutGuide).offset(11)
            }
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(24)
            $0.height.equalTo(listContentHeight)
            $0.bottom.equalTo(scrollView.contentLayoutGuide).offset(-24)
        }
        tableView.reloadData()
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
        updateAccessUI()
    }

    private func setUpStyles() {
        view.backgroundColor = .appColor(.neutral0)
        listContainerView.backgroundColor = .appColor(.neutral0)
        listContainerView.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        listContainerView.layer.borderWidth = 1
        listContainerView.layer.cornerRadius = 20
        listContainerView.clipsToBounds = true
        tableView.backgroundColor = .appColor(.neutral0)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        scrollView.showsVerticalScrollIndicator = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        setUpNavigationBar()
        let message = "로그인을 통해 학기를 편집하고 계절학기와 예비 시간표를 작성할 수 있어요."
        let attributed = NSMutableAttributedString(string: message, attributes: [
            .font: UIFont.appFont(.pretendardMedium, size: 14),
            .foregroundColor: UIColor.appColor(.neutral500)
        ])
        attributed.addAttributes([
            .font: UIFont.appFont(.pretendardSemiBold, size: 14),
            .foregroundColor: UIColor.appColor(.new500)
        ], range: (message as NSString).range(of: "로그인"))
        accessNoticeLabel.attributedText = attributed
        accessNoticeLabel.numberOfLines = 0
        accessNoticeLabel.isUserInteractionEnabled = true
        accessNoticeLabel.accessibilityTraits = .button
        accessNoticeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(accessNoticeTapped)))
        emptyStateView.axis = .vertical
        emptyStateView.alignment = .center
        emptyStateView.spacing = 12
        emptyStateView.isHidden = true
        emptyImageView.contentMode = .scaleAspectFit
        emptyFrameLabel.text = "등록된 시간표가 없어요.\n우측 상단 버튼을 눌러 시간표를 추가해보세요."
        emptyFrameLabel.textAlignment = .center
        emptyFrameLabel.numberOfLines = 0
        emptyFrameLabel.textColor = .appColor(.neutral500)
        emptyFrameLabel.font = .appFont(.pretendardRegular, size: 14)
    }

    private func setUpLayouts() {
        [emptyImageView, emptyFrameLabel].forEach { emptyStateView.addArrangedSubview($0) }
        listContainerView.addSubview(tableView)
        [accessNoticeLabel, listContainerView].forEach { scrollView.addSubview($0) }
        [scrollView, emptyStateView].forEach { view.addSubview($0) }
    }

    private func setUpConstraints() {
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        accessNoticeLabel.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide).offset(11)
            $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(24)
            $0.height.greaterThanOrEqualTo(52)
        }
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        emptyStateView.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        emptyImageView.snp.makeConstraints {
            $0.width.equalTo(98)
            $0.height.equalTo(75)
        }
        emptyFrameLabel.snp.makeConstraints { $0.width.equalTo(258) }
    }

    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.appImage(asset: .timetableSquarePen), style: .plain, target: self, action: #selector(modifySemesterButtonTapped))
        navigationItem.rightBarButtonItem?.accessibilityLabel = "학기 편집"
    }
}
