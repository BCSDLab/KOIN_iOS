//
//  AddDirectCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

final class AddDirectCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    var cancellables = Set<AnyCancellable>()
    let deleteButtonPublisher = PassthroughSubject<Void, Never>()
    let rowChangedPublisher = PassthroughSubject<AddDirectCollectionView.Row, Never>()
    private var row = AddDirectCollectionView.Row()
    private var inputSubscriptions = Set<AnyCancellable>()

    // MARK: - UI Components
    let selectTimeView = SelectTimeView(frame: .zero, size: .small)
    private let placeView = ClassComponentView(text: "장소", isPoint: false)
    private let deleteButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        bind()
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
    
    func configure(row: AddDirectCollectionView.Row) {
        self.row = row
        selectTimeView.configure(row: row)
        placeView.setText(row.place)
    }

    private func bind() {
        placeView.textChangedPublisher.sink { [weak self] value in
            guard let self else { return }
            self.row.place = value
            self.rowChangedPublisher.send(self.row)
        }.store(in: &inputSubscriptions)
        selectTimeView.selectionChangedPublisher.sink { [weak self] in
            guard let self else { return }
            self.row.day = self.selectTimeView.dayIndex
            self.row.startMinute = self.selectTimeView.startMinute
            self.row.endMinute = self.selectTimeView.endMinute
            self.rowChangedPublisher.send(self.row)
        }.store(in: &inputSubscriptions)
    }
}

extension AddDirectCollectionViewCell {
    @objc private func deleteButtonTapped() {
        deleteButtonPublisher.send()
    }
}

extension AddDirectCollectionViewCell {
    private func setUpLayouts() {
        [selectTimeView, placeView, deleteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        deleteButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(12)
            $0.size.equalTo(16)
        }
        selectTimeView.snp.makeConstraints {
            $0.top.equalTo(deleteButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(35)
        }
        placeView.snp.makeConstraints {
            $0.top.equalTo(selectTimeView.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(selectTimeView)
            $0.height.equalTo(35)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }

    private func setUpStyles() {
        contentView.layer.borderColor = UIColor.appColor(.neutral300).cgColor
        contentView.layer.borderWidth = 0.5
        contentView.layer.cornerRadius = 16
        deleteButton.setImage(UIImage.appImage(asset: .cancel)?.withRenderingMode(.alwaysTemplate), for: .normal)
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.tintColor = .appColor(.neutral800)
        deleteButton.accessibilityLabel = "시간 및 장소 삭제"
    }

    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
}
