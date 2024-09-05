//
//  PolicyContentCollectionView.swift
//  koin
//
//  Created by 김나훈 on 9/5/24.
//

import UIKit

final class PolicyContentCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var policyTexts: [PolicyText] = []
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        isScrollEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(PolicyContentCollectionViewCell.self, forCellWithReuseIdentifier: PolicyContentCollectionViewCell.identifier)
        dataSource = self
        delegate = self
    }
    
    func setUpPolicyList(type: PolicyType) {
        policyTexts = PolicyModel.shared.getPolicyTexts(for: type).enumerated().map { (index, policy) in
            PolicyText(title:  "제 \(index+1)조 (\(policy.title))", content: policy.content)
        }
        reloadData()
    }
    
}

extension PolicyContentCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return policyTexts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PolicyContentCollectionViewCell.identifier, for: indexPath) as? PolicyContentCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(policyText: policyTexts[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let estimatedHeight: CGFloat = 1000
        let dummyCell = PolicyContentCollectionViewCell(frame: CGRect(x: 0, y: 0, width: width, height: estimatedHeight))
        dummyCell.configure(policyText: policyTexts[indexPath.row])
        dummyCell.setNeedsLayout()
        dummyCell.layoutIfNeeded()
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: width, height: estimatedSize.height)
    }
}
