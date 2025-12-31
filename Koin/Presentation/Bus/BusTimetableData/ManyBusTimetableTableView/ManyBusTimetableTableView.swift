//
//  ManyBusTimetableTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/7/24.
//

import Combine
import UIKit

final class ManyBusTimetableTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    private var busPlaces: [NodeInfo] = []
    let contentHeightPublisher = PassthroughSubject<CGFloat, Never>()
    
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(ManyBusTimetableTableViewCell.self, forCellReuseIdentifier: ManyBusTimetableTableViewCell.identifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        backgroundColor = .systemBackground
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentHeightPublisher.send(self.contentSize.height)
    }
    
    func configure(timetable: [NodeInfo]) {
        self.busPlaces = timetable
        reloadData()
    }
}

extension ManyBusTimetableTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ManyBusTimetableTableViewCell.identifier, for: indexPath) as? ManyBusTimetableTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configure(busPlace: busPlaces[indexPath.row].name, subBusPlace: busPlaces[indexPath.row].detail)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = .appColor(.neutral100)

        let placeGuideLabel = UILabel()
        placeGuideLabel.text = "승하차장명"
        placeGuideLabel.font = .appFont(.pretendardRegular, size: 14)
        placeGuideLabel.textColor = .appColor(.neutral600)
        placeGuideLabel.textAlignment = .left

        container.addSubview(placeGuideLabel)

        placeGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
        }

        return container
    }
}

extension ManyBusTimetableTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
}
