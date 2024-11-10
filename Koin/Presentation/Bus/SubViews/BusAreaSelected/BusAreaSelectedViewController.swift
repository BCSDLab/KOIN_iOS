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
    let busAreaPublisher = PassthroughSubject<String, Never>()
    private var busRouteType = 0 // 0이면 출발, 1이면 도착
    private var busAreaLists: [BusPlace] = []
    
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
    
    private let confirmButton = UIButton().then {
        $0.backgroundColor = .appColor(.primary500)
        $0.layer.cornerRadius = 4
    }
    
    //MARK: - Initialization
    init(busRouteType: Int, busAreaLists: [BusPlace]) {
        self.busRouteType = busRouteType
        self.busAreaLists = busAreaLists
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
        setUpView()
        busAreaCollectionView.delegate = self
        busAreaCollectionView.dataSource = self
        busAreaCollectionView.reloadData()
    }
}

extension BusAreaSelectedViewController {
    private func setUpView() {
        let attributeContainer: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(.pretendardMedium, size: 15), .foregroundColor: UIColor.appColor(.neutral0)]
        if busRouteType == 0 { // 출발지 고르는 경우
            busRouteDescriptionlabel.text = "어디서 출발하시나요?"
            confirmButton.setAttributedTitle(NSAttributedString(string: "도착지 선택하기", attributes: attributeContainer), for: .normal)
        }
        else { // 도착지 고르는 경우
            busRouteDescriptionlabel.text = "목적지가 어디인가요?"
            confirmButton.setAttributedTitle(NSAttributedString(string: "확인하기", attributes: attributeContainer), for: .normal)
        }
    }
}

extension BusAreaSelectedViewController {
    
    private func setUpLayOuts() {
        [busRouteDescriptionlabel, busAreaCollectionView, confirmButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        busRouteDescriptionlabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(23)
            $0.leading.equalToSuperview().offset(32)
        }
        busAreaCollectionView.snp.makeConstraints {
            $0.top.equalTo(busRouteDescriptionlabel.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.top.equalTo(busAreaCollectionView.snp.bottom).offset(83)
            $0.height.equalTo(48)
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
        cell.configure(busPlace: busAreaLists[indexPath.row].koreanDescription, isSelected: false)
        return cell
    }
}

extension BusAreaSelectedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel()
        label.text = busAreaLists[indexPath.row].koreanDescription
        label.font = .appFont(.pretendardMedium, size: 15)
        let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 48))
        return CGSize(width: size.width + 32, height: 48)
    }
}

