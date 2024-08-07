////
////  AddClassCollectionViewCell.swift
////  koin
////
////  Created by 김나훈 on 4/3/24.
////
//
//import UIKit
//
//final class AddClassCollectionViewCell: UICollectionViewCell {
//    
//    var buttonTappedAction: ((LectureDTO) -> Void)?
//    private var lectureInfo: LectureDTO?
//    
//    // MARK: - UI Components
//
//    private let classTitleLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.appFont(.pretendardRegular, size: 15)
//        label.textColor = UIColor.appColor(.black)
//        return label
//    }()
//    
//    private let classTimeLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.appFont(.pretendardRegular, size: 12)
//        return label
//    }()
//    
//    private let classInfoLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.appFont(.pretendardRegular, size: 12)
//        return label
//    }()
//    
//    private let addButton: UIButton = {
//        let button = UIButton()
//        button.layer.borderWidth = 1
//        button.titleLabel?.font = UIFont.appFont(.pretendardMedium, size: 15)
//        button.layer.borderColor = UIColor.appColor(.bus1).cgColor
//        button.layer.cornerRadius = 5
//        button.setTitle("추가", for: .normal)
//        button.setTitleColor(UIColor.appColor(.bus1), for: .normal)
//        return button
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureView()
//        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func configure(info: LectureDTO) {
//        lectureInfo = info
//        classTitleLabel.text = info.name
//        classTimeLabel.text = formatClassTimes(info.classTime)
//        classInfoLabel.text = "\(info.department) / \(info.code) / \(info.grades)학점 / \(info.professor)"
//    }
//    
//    @objc private func addButtonTapped() {
//        if let lectureInfo = lectureInfo {
//            buttonTappedAction?(lectureInfo)  
//        }
//    }
//    
//    private func formatClassTimes(_ classTimes: [Int]) -> String {
//        let days = ["월", "화", "수", "목", "금"]
//        var formattedTimes: [String] = []
//        var previousDayIndex: Int?
//
//        for time in classTimes {
//            let dayIndex = time / 100 // 요일을 나타내는 100의 자리 숫자
//            let periodIndex = time % 100 // 시간대를 나타내는 10의 자리와 1의 자리 숫자
//
//            // dayIndex가 배열의 범위를 벗어나지 않는지 확인합니다.
//            let dayString = days.indices.contains(dayIndex) ? days[dayIndex] : "월"
//            let periodString = "\(periodIndex / 2 + 1)\(periodIndex % 2 == 0 ? "A" : "B")"
//
//            if previousDayIndex != dayIndex {
//                formattedTimes.append("\(dayString)\(periodString)")
//            } else {
//                formattedTimes.append(periodString)
//            }
//
//            previousDayIndex = dayIndex
//        }
//
//        return formattedTimes.joined(separator: ", ")
//    }
//
//}
//
//extension AddClassCollectionViewCell {
//    private func setUpLayouts() {
//        [classTitleLabel, classTimeLabel, classInfoLabel, addButton].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            contentView.addSubview($0)
//        }
//    }
//    
//    private func setUpConstraints() {
//        NSLayoutConstraint.activate([
//            classTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 17),
//            classTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
//            classTimeLabel.topAnchor.constraint(equalTo: classTitleLabel.bottomAnchor, constant: 2),
//            classTimeLabel.leadingAnchor.constraint(equalTo: classTitleLabel.leadingAnchor),
//            
//            classInfoLabel.topAnchor.constraint(equalTo: classTimeLabel.bottomAnchor, constant: 2),
//            classInfoLabel.leadingAnchor.constraint(equalTo: classTitleLabel.leadingAnchor),
//            
//            addButton.topAnchor.constraint(equalTo: classTitleLabel.topAnchor),
//            addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
//            addButton.heightAnchor.constraint(equalToConstant: 26),
//            addButton.widthAnchor.constraint(equalToConstant: 56)
//        ])
//    }
//    
//    private func configureView() {
//        setUpLayouts()
//        setUpConstraints()
//        setUpBorder()
//    }
//    
//    private func setUpBorder() {
//        self.layer.borderWidth = 1.0
//        self.layer.borderColor = UIColor.appColor(.borderGray).cgColor
//    }
//}
//
//extension AddClassCollectionViewCell {
//    enum Metrics {
//        
//    }
//    enum Padding {
//        
//    }
//}
