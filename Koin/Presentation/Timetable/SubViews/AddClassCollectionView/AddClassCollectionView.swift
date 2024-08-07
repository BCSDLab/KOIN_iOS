////
////  AddClassCollectionView.swift
////  koin
////
////  Created by 김나훈 on 4/3/24.
////
//
//import Combine
//import UIKit
//
//final class AddClassCollectionView: UICollectionView, UICollectionViewDataSource {
//    
//    private var lectureList: [LectureDTO] = []
//    let addButtonPublisher = PassthroughSubject<LectureDTO, Never>()
//    
//    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
//        super.init(frame: frame, collectionViewLayout: layout)
//        commonInit()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        commonInit()
//    }
//    
//    private func commonInit() {
//        register(AddClassCollectionViewCell.self, forCellWithReuseIdentifier: AddClassCollectionViewCell.identifier)
//        dataSource = self
//    }
//    
//    func setLectureList(_ list: [LectureDTO]) {
//        lectureList = list
//        self.reloadData()
//    }
//    
//}
//
//extension AddClassCollectionView {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return lectureList.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddClassCollectionViewCell.identifier, for: indexPath) as? AddClassCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        let lectureItem = lectureList[indexPath.row]
//        cell.configure(info: lectureItem)
//        cell.buttonTappedAction = { [weak self] lectureDTO in
//            self?.addButtonPublisher.send(lectureDTO)
//        }
//        return cell
//    }
//    
//}
