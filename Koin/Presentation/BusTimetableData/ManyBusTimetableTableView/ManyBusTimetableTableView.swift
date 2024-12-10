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
    private var busPlaces: [String] = ["본교", "천안터미널", "천안역", "본교"]
    
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
    
}

extension ManyBusTimetableTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ManyBusTimetableTableViewCell.identifier, for: indexPath) as? ManyBusTimetableTableViewCell else { return UITableViewCell() }
        cell.configure(busPlace: busPlaces[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let placeGuideLabel = UILabel()
        placeGuideLabel.text = "승하차장명"
        placeGuideLabel.textAlignment = .left
        [placeGuideLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral600)
            view.addSubview($0)
        }
        placeGuideLabel.frame = .init(x: 24, y: 14, width: 132, height: 38)
        
        view.frame = CGRect(x: 0, y: 0, width: 156, height: 52)
        view.backgroundColor = .appColor(.neutral100)
        return view
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






