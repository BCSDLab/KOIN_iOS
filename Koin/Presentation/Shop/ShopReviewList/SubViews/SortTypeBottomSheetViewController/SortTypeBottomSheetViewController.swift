//
//  SortTypeBottomSheetViewController.swift
//  koin
//
//  Created by 이은지 on 10/24/25.
//

import UIKit
import Combine
import SnapKit
import Then

final class SortTypeBottomSheetViewController: UIViewController {
    
    // MARK: - Properties
    
    private let options: [String]
    private let selectedIndex: Int
    private let onSelection: (Int)->Void
    
    // MARK: - Constants
    
    private var bottomSheetHeight: CGFloat {
        let headerHeight: CGFloat = 53
        let separatorHeight: CGFloat = 1
        let cellTotalHeight: CGFloat = CGFloat(options.count) * 46
        let lastCellBottomInset: CGFloat = 20
        let safeAreaBottom: CGFloat = 34
        
        return headerHeight + separatorHeight + cellTotalHeight + lastCellBottomInset + safeAreaBottom
    }
    
    // MARK: - UI Components
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.alpha = 0
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 32
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "정렬"
        $0.font = UIFont.appFont(.pretendardSemiBold, size: 18)
        $0.textColor = UIColor.appColor(.new500)
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage.appImage(asset: .cancel)?.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = UIColor.appColor(.neutral800)
    }
    
    private let separateView1 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    private lazy var sortTypeTableView = UITableView().then {
        $0.register(SortTypeBottomSheetCell.self, forCellReuseIdentifier: SortTypeBottomSheetCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
        $0.backgroundColor = .white
    }
    
    private let separateView2 = UIView().then {
        $0.backgroundColor = UIColor.appColor(.neutral300)
    }
    
    // MARK: - Initialize
    
    init(
        options: [String],
        selectedIndex: Int = 0,
        onSelection: @escaping (Int)->Void
    ) {
        self.options = options
        self.selectedIndex = selectedIndex
        self.onSelection = onSelection
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setAddTarget()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    private func setAddTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        containerView.addGestureRecognizer(panGesture)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
}

// MARK: - @objc

extension SortTypeBottomSheetViewController {
    
    @objc private func dimmedViewTapped() {
        hideBottomSheet()
    }
    
    @objc private func closeButtonTapped() {
        hideBottomSheet()
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            if translation.y > 100 || velocity.y > 500 {
                hideBottomSheet()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.containerView.transform = .identity
                }
            }
        default:
            break
        }
    }
}

// MARK: - Animation

extension SortTypeBottomSheetViewController {
    
    private func showBottomSheet() {
        containerView.transform = CGAffineTransform(translationX: 0, y: bottomSheetHeight)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut
        ) {
            self.containerView.transform = .identity
            self.dimmedView.alpha = 1
        }
    }
    
    private func hideBottomSheet(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut
        ) {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.bottomSheetHeight)
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
}

// MARK: - UI Function

extension SortTypeBottomSheetViewController {
    
    private func setUpLayout() {
        [dimmedView, containerView].forEach {
            view.addSubview($0)
        }
        
        [titleLabel, closeButton, separateView1, sortTypeTableView, separateView2].forEach {
            containerView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(bottomSheetHeight)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(32)
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.height.equalTo(24)
        }
        
        separateView1.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0.5)
        }
        
        sortTypeTableView.snp.makeConstraints {
            $0.top.equalTo(separateView1.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(CGFloat(options.count * 56))
        }
        
        separateView2.snp.makeConstraints {
            $0.top.equalTo(sortTypeTableView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
    
    private func configureView() {
        view.backgroundColor = .clear
        setUpLayout()
        setupConstraints()
    }
}

// MARK: - UITableViewDataSource
extension SortTypeBottomSheetViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SortTypeBottomSheetCell.identifier,
            for: indexPath
        ) as? SortTypeBottomSheetCell else {
            return UITableViewCell()
        }
        
        let isSelected = indexPath.row == selectedIndex
        cell.configure(text: options[indexPath.row], isSelected: isSelected)
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SortTypeBottomSheetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        onSelection(indexPath.row)
        hideBottomSheet()
    }
}
