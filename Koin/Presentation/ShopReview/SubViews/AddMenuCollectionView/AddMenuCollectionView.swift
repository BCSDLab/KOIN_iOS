//
//  AddMenuCollectionView.swift
//  koin
//
//  Created by 김나훈 on 8/13/24.
//

import Combine
import UIKit

final class AddMenuCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {
        
    struct MenuItem: Hashable {
        let id = UUID()
        var title: String
    }
    
    private enum Section: CaseIterable { case main }

    let menuItemCountPublisher = PassthroughSubject<Int, Never>()
    var menuItem: [String] { return menuItemInternal.map { $0.title } }
    private var menuItemInternal: [MenuItem] = []
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, MenuItem>!

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = .zero
        register(AddMenuCollectionViewCell.self, forCellWithReuseIdentifier: AddMenuCollectionViewCell.identifier)
        configureDataSource()
        delegate = self
    }
    
    func addMenuItem() {
        menuItemInternal.append(MenuItem(title: ""))
        menuItemCountPublisher.send(menuItem.count)
        applySnapshot()
    }
    
    func setMenuItem(item: [String]) {
        menuItemInternal = item.map { MenuItem(title: $0) }
        menuItemCountPublisher.send(menuItem.count)
        applySnapshot()
    }
    
    private func configureDataSource() {
        diffableDataSource = UICollectionViewDiffableDataSource<Section, MenuItem>(collectionView: self) { [weak self] collectionView, indexPath, item in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddMenuCollectionViewCell.identifier, for: indexPath) as? AddMenuCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(text: item.title)

            cell.cancelButtonPublisher.sink { [weak self] in
                guard let self = self else { return }
                if let index = self.menuItemInternal.firstIndex(where: { $0.id == item.id }) {
                    self.menuItemInternal.remove(at: index)
                    self.menuItemCountPublisher.send(self.menuItemInternal.count)
                    self.applySnapshot()
                }
            }.store(in: &cell.cancellables)
            
            cell.textPublisher.sink { [weak self] text in
                guard let self = self else { return }
                if let index = self.menuItemInternal.firstIndex(where: { $0.id == item.id }) {
                    self.menuItemInternal[index].title = text
                }
            }.store(in: &cell.cancellables)

            return cell
        }
        self.dataSource = diffableDataSource
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MenuItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(menuItemInternal)
        diffableDataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension AddMenuCollectionView {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Int(collectionView.bounds.width), height: 46)
    }
}
