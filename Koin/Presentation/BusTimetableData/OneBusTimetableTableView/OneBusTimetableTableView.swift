//
//  OneBusTimetableTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 12/5/24.
//

import Combine
import UIKit

final class OneBusTimetableTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    private var busInfo: ([NodeInfo], [String?]) = ([], [])
    
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
        register(OneBusTimetableTableViewCell.self, forCellReuseIdentifier: OneBusTimetableTableViewCell.identifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        isScrollEnabled = false
        backgroundColor = .systemBackground
    }
    
    func configure(nodeInfo: [NodeInfo], routeInfo: [String?]) {
        self.busInfo = (nodeInfo, routeInfo)
        reloadData()
    }
}

extension OneBusTimetableTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busInfo.1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: OneBusTimetableTableViewCell.identifier, for: indexPath) as? OneBusTimetableTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.configure(busPlace: busInfo.0[indexPath.row], busTime: busInfo.1[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let timeGuideLabel = UILabel()
        let placeGuideLabel = UILabel()
        timeGuideLabel.text = "등교"
        placeGuideLabel.text = "승하차장명"
        timeGuideLabel.textAlignment = .center
        placeGuideLabel.textAlignment = .left
        [timeGuideLabel, placeGuideLabel].forEach {
            $0.font = .appFont(.pretendardRegular, size: 14)
            $0.textColor = .appColor(.neutral600)
            view.addSubview($0)
        }
        timeGuideLabel.frame = .init(x: 24, y: 18, width: 62, height: 22)
        placeGuideLabel.frame = .init(x: 104, y: 18, width: 200, height: 22)
        
        view.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 52)
        view.backgroundColor = .appColor(.neutral100)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}

extension OneBusTimetableTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 52
    }
}





