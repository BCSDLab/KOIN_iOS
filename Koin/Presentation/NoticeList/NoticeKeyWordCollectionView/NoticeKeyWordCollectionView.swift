//
//  NoticeKeyWordCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Combine
import UIKit

final class NoticeKeyWordCollectionView: UICollectionView, UICollectionViewDataSource {
    //MARK: - Properties
    private var noticeKeyWordList: [NoticeKeyWordDTO] = []
    let keyWordTapPublisher = PassthroughSubject<NoticeKeyWordDTO, Never>()
    let keyWordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    var subscriptions = Set<AnyCancellable>()
    var selectedKeyWordIdx = 0
    
    //MARK: - Initialization
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(NoticeKeyWordCollectionViewCell.self, forCellWithReuseIdentifier: NoticeKeyWordCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    func updateUserKeyWordList(keyWordList: [NoticeKeyWordDTO], keyWordIdx: Int) {
        // 모두보기 키워드는 viewModel에서 넣어서 오기 때문에 배열의 개수가 하나일 때, 알림설정 키워드가 없음.
        noticeKeyWordList.removeAll()
        if keyWordList.count == 0 {
            noticeKeyWordList.append(NoticeKeyWordDTO(id: nil, keyWord: "새 키워드 추가"))
        }
        else { // id가 -1일때 모두보기이다.
            noticeKeyWordList.append(NoticeKeyWordDTO(id: -1, keyWord: "모두보기"))
        }
        noticeKeyWordList.append(contentsOf: keyWordList)
        selectedKeyWordIdx = keyWordIdx
        reloadData()
    }
<<<<<<< HEAD
    
    func selectKeyWord(keyWord: String) {
        for index in 0..<noticeKeyWordList.count {
            let indexPath = IndexPath(item: index+1, section: 0)
            if let cell = cellForItem(at: indexPath) as? NoticeKeyWordCollectionViewCell {
                let isSelected = noticeKeyWordList[index].keyWord == keyWord
                cell.configure(keyWordModel: noticeKeyWordList[index].keyWord, isSelected: isSelected)
            }
        }
    }

=======
>>>>>>> a8c0b4b (chore: 키워드가 적절하게 초기화될 수 있도록 변경)
}

extension NoticeKeyWordCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noticeKeyWordList.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeKeyWordCollectionViewCell.identifier, for: indexPath) as? NoticeKeyWordCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.item == 0 {
            cell.configureFilterImage()
        } else if indexPath.item - 1 < noticeKeyWordList.count {
            let keyWord = noticeKeyWordList[indexPath.item - 1].keyWord
            let isSelected = selectedKeyWordIdx + 1 == indexPath.item
            cell.configure(keyWordModel: keyWord, isSelected: isSelected)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 || noticeKeyWordList[indexPath.row-1].keyWord == "새 키워드 추가"{
            keyWordAddBtnTapPublisher.send()
        }
        else {
            keyWordTapPublisher.send(noticeKeyWordList[indexPath.row-1])
        }
    }
}

extension NoticeKeyWordCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: 32, height: 32)
        } else {
            let label = UILabel()
            label.text = noticeKeyWordList[indexPath.item-1].keyWord
            label.font = .appFont(.pretendardBold, size: 14)
            let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
            return CGSize(width: size.width + 32, height: 34)
        }
    }
}

