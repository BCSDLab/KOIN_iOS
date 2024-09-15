//
//  ScoreChartCollectionViewCell.swift
//  koin
//
//  Created by 김나훈 on 8/11/24.
//

import Then
import UIKit

final class ScoreChartCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let scoreLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .right
    }
    
    private let progressView = UIProgressView().then {
        $0.trackTintColor = UIColor.appColor(.neutral300)
        $0.progressTintColor = UIColor.appColor(.warning500)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
        $0.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               $0.heightAnchor.constraint(equalToConstant: 7)
           ])
    }
    
    private let scoreCountLabel = UILabel().then {
        $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        $0.textColor = UIColor.appColor(.neutral500)
        $0.textAlignment = .left
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(score: String, count: Int, totalCount: Int) {
        scoreLabel.text = "\(score)점"
        scoreCountLabel.text = "\(count)"
        if totalCount == 0 {
            progressView.progress = 0
        } else {
            progressView.progress = Float(count) / Float(totalCount)
        }
    }

}

extension ScoreChartCollectionViewCell {
    private func setUpLayouts() {
        [scoreLabel, progressView, scoreCountLabel].forEach {
            self.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        scoreLabel.snp.makeConstraints {
            $0.leading.equalTo(self.snp.leading)
            $0.centerY.equalTo(self.snp.centerY)
            $0.width.equalTo(19)
        }
        progressView.snp.makeConstraints {
            $0.leading.equalTo(scoreLabel.snp.trailing).offset(12)
            $0.trailing.equalTo(scoreCountLabel.snp.leading).offset(-12)
            $0.centerY.equalTo(self.snp.centerY)
        }
        scoreCountLabel.snp.makeConstraints {
            $0.trailing.equalTo(self.snp.trailing)
            $0.centerY.equalTo(self.snp.centerY)
            $0.width.equalTo(40)
        }
    }
    
    private func configureView() {
        setUpLayouts()
        setUpConstraints()
    }
    
}
