//
//  TagCollectionView.swift
//  koin
//
//  Created by 김성민 on 11/4/25.
//

import UIKit

final class TagCollectionView: UICollectionView, UICollectionViewDataSource,    UICollectionViewDelegateFlowLayout {
    
    var maxCount: Int = 5
    private(set) var items: [String] = []
    var onHeightChange: ((CGFloat) -> Void)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit(){
        backgroundColor = .clear
        delegate = self
        dataSource = self
        register(TagCollectionViewCell.self, forCellWithReuseIdentifier: TagCollectionViewCell.identifier)
    }
    
    func add(_ tagText: String) {
        let text = tagText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        guard items.count < maxCount else { return }
        items.append(text)
        reloadAndPublish()
    }
    
    func remove(_ index: Int){
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        reloadAndPublish()
    }
    
    private func reloadAndPublish() {
        reloadData()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let height = self.collectionViewLayout.collectionViewContentSize.height
            self.onHeightChange?(height)
        }
    }
}

extension TagCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else {
            return UICollectionViewCell()
        }
        let title = items[indexPath.item]
        cell.configure(title: title)
        
        cell.onTapCancel = { [weak self, weak cell] in
            guard let self = self,
                  let cell = cell,
                  let index = self.indexPath(for: cell)?.item else { return }
            self.remove(index)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = items[indexPath.item]
        let fontWidth = (title as NSString).size(withAttributes: [.font: UIFont.appFont(.pretendardRegular, size: 12)]).width

        return CGSize(width: fontWidth + 40, height: 25)
    }
}
