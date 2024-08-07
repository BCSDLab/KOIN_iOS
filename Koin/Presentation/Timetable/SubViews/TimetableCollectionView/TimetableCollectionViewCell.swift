////
////  TimeTableCollectionViewCell.swift
////  koin
////
////  Created by 김나훈 on 3/30/24.
////
//
//import SnapKit
//import UIKit
//
//final class TimetableCollectionViewCell: UICollectionViewCell {
//    
//    var cellId: [Int?] = [nil, nil, nil, nil, nil]
//    var onTap: ((Int) -> Void)?
//    
//    // MARK: - UI Components
//    
//    private let codeLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.appColor(.textGray)
//        label.textAlignment = .center
//        label.font = UIFont.appFont(.pretendardRegular, size: 10)
//        return label
//    }()
//    
//    private let timeLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = UIColor.appColor(.textGray)
//        label.textAlignment = .center
//        label.font = UIFont.appFont(.pretendardRegular, size: 10)
//        return label
//    }()
//    
//    private lazy var stackView: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .horizontal
//        stack.distribution = .fillEqually
//        stack.alignment = .fill
//        stack.spacing = 0
//        return stack
//    }()
//    
//    private var timeTableLabel: [UILabel] = {
//        var labelsArray = [UILabel]()
//        for _ in 1...5 {
//            let label = UILabel()
//            label.textAlignment = .left
//            label.numberOfLines = 0
//            label.font = UIFont.appFont(.pretendardRegular, size: 10)
//            labelsArray.append(label)
//        }
//        return labelsArray
//    }()
//    
//    private let cellBackground: [UIView] = {
//        var viewArray = [UIView]()
//        for _ in 1...5 {
//            let view = UIView()
//            viewArray.append(view)
//            
//        }
//        return viewArray
//    }()
//    
//    private let bottomBorderView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.appColor(.borderGray)
//        return view
//    }()
//    
//    private let leftBorder: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.appColor(.simpleGray)
//        return view
//    }()
//    
//    private let rightBorder: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor.appColor(.simpleGray)
//        return view
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureView()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        timeTableLabel.forEach { label in
//            label.text = nil
//        }
//        cellBackground.forEach { view in
//            view.backgroundColor = .clear
//        }
//    }
//}
//
//extension TimetableCollectionViewCell {
//    
//    func removeInfoById(_ id: Int) {
//        // id 값에 해당하는 인덱스 찾기
//        guard let index = cellId.firstIndex(of: id) else { return }
//        
//        // 해당 인덱스의 정보 제거
//        timeTableLabel[index].text = nil
//        cellBackground[index].backgroundColor = .clear
//        
//        cellId[index] = nil
//    }
//    private func addTapGesturesToViews() {
//        for (index, view) in cellBackground.enumerated() {
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
//            view.isUserInteractionEnabled = true
//            view.addGestureRecognizer(tapGesture)
//            view.tag = index // 인덱스를 태그로 사용하여 나중에 식별
//        }
//    }
//    
//    @objc private func handleLabelTap(_ sender: UITapGestureRecognizer) {
//        guard let label = sender.view, let cellId = cellId[label.tag] else { return }
//        onTap?(cellId)
//    }
//    
//    func configure(info: (String, String), isBorder: Bool) {
//        codeLabel.text = info.0
//        timeLabel.text = info.1
//        
//        if isBorder {
//            bottomBorderView.backgroundColor = UIColor.appColor(.simpleGray)
//        }
//        else {
//            bottomBorderView.backgroundColor = UIColor.appColor(.borderGray)
//        }
//    }
//    
//    func updateText(text: String?, index: Int, color: UIColor, id: Int) {
//        timeTableLabel[index].text = text
//        cellBackground[index].backgroundColor = color
//        cellId[index] = id
//    }
//    
//    func removeCellInfo() {
//        timeTableLabel.forEach { label in
//            label.text = nil
//        }
//        cellBackground.forEach { view in
//            view.backgroundColor = .systemBackground
//        }
//        cellId = [nil, nil, nil, nil, nil]
//    }
//}
//
//extension TimetableCollectionViewCell {
//    
//    private func setUpLayouts() {
//        cellBackground.forEach { view in
//            stackView.addArrangedSubview(view)
//        }
//        
//        [codeLabel, timeLabel, stackView].forEach {
//            self.addSubview($0)
//        }
//        
//        timeTableLabel.forEach { label in
//            self.addSubview(label)
//        }
//        
//    }
//    
//    private func setUpConstraints() {
//        codeLabel.snp.makeConstraints { make in
//            make.top.equalTo(self.snp.top)
//            make.leading.equalTo(self.snp.leading)
//            make.height.equalTo(self.snp.height)
//            make.width.equalTo(Metrics.labelWidth)
//        }
//        timeLabel.snp.makeConstraints { make in
//            make.top.equalTo(self.snp.top)
//            make.leading.equalTo(codeLabel.snp.trailing)
//            make.height.equalTo(self.snp.height)
//            make.width.equalTo(Metrics.labelWidth)
//        }
//        stackView.snp.makeConstraints { make in
//            make.leading.equalTo(timeLabel.snp.trailing)
//            make.trailing.equalToSuperview()
//            make.top.bottom.equalToSuperview()
//        }
//        //timetablelabel
//        //cellbackground
//        for i in 0..<timeTableLabel.count {
//            let label = timeTableLabel[i]
//            let view = cellBackground[i]
//            label.snp.makeConstraints { make in
//                make.leading.equalTo(view.snp.leading)
//                make.trailing.equalTo(view.snp.trailing)
//            }
//        }
//        
//    }
//    
//    private func addBorder() {
//        [bottomBorderView, leftBorder, rightBorder].forEach {
//            addSubview($0)
//        }
//        
//        leftBorder.snp.makeConstraints { make in
//            make.leading.equalTo(timeLabel.snp.leading)
//            make.bottom.equalTo(timeLabel.snp.bottom)
//            make.top.equalTo(timeLabel.snp.top)
//            make.width.equalTo(1)
//        }
//        
//        rightBorder.snp.makeConstraints { make in
//            make.trailing.equalTo(timeLabel.snp.trailing)
//            make.bottom.equalTo(timeLabel.snp.bottom)
//            make.top.equalTo(timeLabel.snp.top)
//            make.width.equalTo(1)
//        }
//        
//        bottomBorderView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.height.equalTo(Metrics.bottomHeight)
//        }
//    }
//    
//    private func configureView() {
//        setUpLayouts()
//        setUpConstraints()
//        addBorder()
//        self.clipsToBounds = false
//        timeTableLabel.forEach { $0.clipsToBounds = false }
//        timeTableLabel.forEach { $0.layer.zPosition = 1 }
//        addTapGesturesToViews()
//        self.backgroundColor = .systemBackground
//    }
//    
//}
//
//extension TimetableCollectionViewCell {
//    enum Metrics {
//        static let labelHeight: CGFloat = 30
//        static let labelWidth: CGFloat = 40
//        static var bottomHeight: CGFloat = 1
//    }
//    enum Padding {
//        
//    }
//}
