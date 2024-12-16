//
//  BusAreaSelectedViewController.swift
//  koin
//
//  Created by JOOMINKYUNG on 11/10/24.
//

import Combine
import Then
import UIKit

final class BusAreaSelectedViewController: UIViewController {
    //MARK: - Properties
    let busAreaPublisher = PassthroughSubject<(BusPlace, BusPlace), Never>()
    private var busRouteType = 0 // 0이면 출발, 1이면 도착
    private var busAreaLists: [(BusPlace, Bool)] = []
    private var buttonState: BusAreaButtonState = .allSelected
    private var selectedArea: (BusPlace?, BusPlace?) = (nil, nil)
    
    //MARK: - UI Components
    private let busRouteDescriptionlabel = UILabel().then {
        $0.font = .appFont(.pretendardBold, size: 18)
        $0.textColor = .appColor(.neutral800)
    }
    
    private let busAreaCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 14
        $0.collectionViewLayout = layout
        $0.contentInset = .init(top: 16, left: 32, bottom: 16, right: 32)
    }
    
    private let separateView = UIView().then {
        $0.backgroundColor = .appColor(.neutral300)
    }
    
    private let confirmButton = UIButton().then {
        $0.backgroundColor = .appColor(.primary500)
        $0.layer.cornerRadius = 4
    }
    
    //MARK: - Initialization
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        busAreaCollectionView.register(BusAreaSelectedCollectionViewCell.self, forCellWithReuseIdentifier: BusAreaSelectedCollectionViewCell.identifier)
        configureView()
        busAreaCollectionView.delegate = self
        busAreaCollectionView.dataSource = self
        confirmButton.addTarget(self, action: #selector(tapConfirmButton), for: .touchUpInside)
    }
}

extension BusAreaSelectedViewController {
    func configure(busRouteType: Int, busAreaLists: [(BusPlace, Bool)], buttonState: BusAreaButtonState) {
        self.busRouteType = busRouteType
        self.busAreaLists = busAreaLists
        self.buttonState = buttonState
        setUpView()
        busAreaCollectionView.reloadData()
    }
    
    private func setUpView() {
        let attributeContainer: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(.pretendardMedium, size: 15), .foregroundColor: UIColor.appColor(.neutral0)]
        var confirmButtonTitle: String = ""
        switch buttonState {
        case .notSelected:
            confirmButtonTitle = busRouteType == 0 ? "도착지 선택하기" : "출발지 선택하기"
        default:
            confirmButtonTitle = "확인하기"
        }
        confirmButton.setAttributedTitle(NSAttributedString(string: confirmButtonTitle, attributes: attributeContainer), for: .normal)
        if busRouteType == 0 { // 출발지 고르는 경우
            busRouteDescriptionlabel.text = "어디서 출발하시나요?"
        }
        else { // 도착지 고르는 경우
            busRouteDescriptionlabel.text = "목적지가 어디인가요?"
        }
    }
    
    
    @objc private func tapConfirmButton() {
        switch buttonState {
        case .notSelected:
            handleNotSelectedState()  //아무것도 선택하지 않은 상태일때
        default:
            handleSelectedState() // 출발지, 도착지 중 하나를 선택한 상태일때
        }
        
        configure(busRouteType: busRouteType, busAreaLists: busAreaLists, buttonState: buttonState)
    }

    private func handleNotSelectedState() {
        buttonState = busRouteType == 0 ? .departureSelected : .arrivalSelected
        updateSelectedArea()
        toggleBusAreaSelection()
        busRouteType = busRouteType == 0 ? 1 : 0
    }

    private func handleSelectedState() {
        let area = busRouteType == 0 ? selectedArea.0 : selectedArea.1
        updateSelectedAreaIfNeeded(area: area)
        
        if let departedArea = selectedArea.0, let arrivedArea = selectedArea.1 {
            busAreaPublisher.send((departedArea, arrivedArea))
        }
        
        selectedArea = (nil, nil)
        dismissView()
    }

    private func updateSelectedArea() {
        for (index, value) in busAreaLists.enumerated() {
            if value.1 {
                if busRouteType == 0 {
                    selectedArea.0 = value.0
                } else {
                    selectedArea.1 = value.0
                }
            }
        }
    }

    private func toggleBusAreaSelection() {
        var isChecked = false
        for (index, _) in busAreaLists.enumerated() {
            if busAreaLists[index].1 == false && !isChecked {
                busAreaLists[index].1 = true
                isChecked = true
            } else {
                busAreaLists[index].1 = false
            }
        }
    }

    private func updateSelectedAreaIfNeeded(area: BusPlace?) {
        for (_, value) in busAreaLists.enumerated() {
            if value.1, area == nil {
                if busRouteType == 0 {
                    selectedArea.0 = value.0
                } else {
                    selectedArea.1 = value.0
                }
            }
        }
    }
}

extension BusAreaSelectedViewController {
    
    private func setUpLayOuts() {
        [busRouteDescriptionlabel, busAreaCollectionView, confirmButton, separateView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busRouteDescriptionlabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(32)
        }
        busAreaCollectionView.snp.makeConstraints {
            $0.top.equalTo(separateView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(160)
        }
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.top.equalTo(busAreaCollectionView.snp.bottom)
            $0.height.equalTo(48)
        }
        separateView.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(busRouteDescriptionlabel.snp.bottom).offset(12)
        }
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}

extension BusAreaSelectedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busAreaLists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusAreaSelectedCollectionViewCell.identifier, for: indexPath) as? BusAreaSelectedCollectionViewCell else {
            return UICollectionViewCell()
        }
        let item = busAreaLists[indexPath.row]
        let busPlace = busRouteType == 0 ? selectedArea.1 : selectedArea.0
        cell.configure(busPlace: item.0.koreanDescription, isSelected: item.1)
        if let busPlace = busPlace, busPlace == busAreaLists[indexPath.row].0 {
            cell.disableCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndex = indexPath.row
        for (index, _) in busAreaLists.enumerated() {
            busAreaLists[index].1 = (index == selectedIndex)
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let area = busRouteType == 0 ? selectedArea.1 : selectedArea.0
        let isEnabled = busAreaLists[indexPath.row].0 != area
        return isEnabled
    }
}

extension BusAreaSelectedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = busAreaLists[indexPath.row].0.koreanDescription
        label.font = .appFont(.pretendardMedium, size: 15)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 48))
        return CGSize(width: size.width + 32, height: 48)
    }
}
