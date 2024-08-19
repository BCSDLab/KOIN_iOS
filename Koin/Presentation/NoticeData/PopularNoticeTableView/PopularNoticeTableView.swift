//
//  PopularNoticeTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/19/24.
//

import Combine
import UIKit

final class PopularNoticeTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    
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
        register(NoticeListTableViewCell.self, forCellReuseIdentifier: NoticeListTableViewCell.identifier)
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}


