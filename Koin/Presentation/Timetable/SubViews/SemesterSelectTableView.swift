//
//  SemesterSelectTableView.swift
//  koin
//
//  Created by 김나훈 on 4/1/24.
//

import Combine
import SnapKit
import UIKit

class SemesterSelectTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    var semesters: [SemesterDTO] = []
    var didSelectSemester: ((SemesterDTO) -> Void)?
    var didTapCompleteButton = PassthroughSubject<Void, Never>()
    
    private let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let headerBlack: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral500)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.appFont(.pretendardRegular, size: 14)
        label.textColor = UIColor.appColor(.primary500)
        label.text = "학기선택"
        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 14)
        button.setTitleColor(UIColor.appColor(.neutral800), for: .normal)
        return button
    }()
    
    private let separateView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.appColor(.neutral500)
        return view
    }()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.delegate = self
        self.dataSource = self
        self.register(UITableViewCell.self, forCellReuseIdentifier: "SemesterCell")
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        setupHeaderView()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func completeButtonTapped() {
        didTapCompleteButton.send()  
    }
    
    func setupHeaderView() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        
        self.tableHeaderView = headerView
        headerView.addSubview(titleLabel)
        headerView.addSubview(separateView)
        headerView.addSubview(completeButton)
        headerView.addSubview(headerBlack)
        
        headerBlack.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.top)
            make.leading.equalTo(headerView.snp.leading)
            make.trailing.equalTo(headerView.snp.trailing)
            make.height.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(headerView.snp.centerX)
            make.centerY.equalTo(headerView.snp.centerY)
        }
        
        separateView.snp.makeConstraints { make in
            make.width.equalTo(headerView.snp.width)
            make.height.equalTo(1)
            make.top.equalTo(headerView.snp.bottom)
        }
        completeButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerView.snp.centerY)
            make.right.equalTo(headerView.snp.right).offset(-22)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semesters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SemesterCell", for: indexPath)
        cell.textLabel?.text = semesters[indexPath.row].formattedSemester
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSemester = semesters[indexPath.row]
        didSelectSemester?(selectedSemester)
    }
}
