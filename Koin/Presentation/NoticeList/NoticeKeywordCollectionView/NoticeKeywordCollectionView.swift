//
//  NoticeKeywordCollectionView.swift
//  koin
//
//  Created by JOOMINKYUNG on 8/13/24.
//

import Combine
import UIKit

final class NoticeKeywordCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {
    //MARK: - Properties
    private var noticeKeywordList: [NoticeKeywordDTO] = []
    let keywordTapPublisher = PassthroughSubject<NoticeKeywordDTO, Never>()
    let keywordAddBtnTapPublisher = PassthroughSubject<(), Never>()
    var subscriptions = Set<AnyCancellable>()
    var selectedKeywordIdx = 0
    
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
        register(NoticeKeywordCollectionViewCell.self, forCellWithReuseIdentifier: NoticeKeywordCollectionViewCell.identifier)
        dataSource = self
        delegate = self
        showsHorizontalScrollIndicator = false
        contentInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
    
    func updateUserKeywordList(keywordList: [NoticeKeywordDTO], keywordIdx: Int) {
        // 모두보기 키워드는 viewModel에서 넣어서 오기 때문에 배열의 개수가 하나일 때, 알림설정 키워드가 없음.
        noticeKeywordList.removeAll()
        if keywordList.count == 0 {
            noticeKeywordList.append(NoticeKeywordDTO(id: -1, keyword: "모두보기"))
            noticeKeywordList.append(NoticeKeywordDTO(id: nil, keyword: "새 키워드 추가"))
        }
        else { // id가 -1일때 모두보기이다.
            noticeKeywordList.append(NoticeKeywordDTO(id: -1, keyword: "모두보기"))
        }
        noticeKeywordList.append(contentsOf: keywordList)
        selectedKeywordIdx = keywordIdx
        reloadData()
    }
    
    func selectKeyword(keyword: String) {
        for index in 0..<noticeKeywordList.count {
            let indexPath = IndexPath(item: index + 1, section: 0)
            if let cell = cellForItem(at: indexPath) as? NoticeKeywordCollectionViewCell {
                let isSelected = noticeKeywordList[index].keyword == keyword
                cell.configure(keywordModel: noticeKeywordList[index].keyword, isSelected: isSelected)
            }
        }
    }

}

extension NoticeKeywordCollectionView {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noticeKeywordList.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeKeywordCollectionViewCell.identifier, for: indexPath) as? NoticeKeywordCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.item == 0 {
            cell.configureFilterImage()
        } else if indexPath.item - 1 < noticeKeywordList.count {
            let keyword = noticeKeywordList[indexPath.item - 1].keyword
            let isSelected = selectedKeywordIdx + 1 == indexPath.item
            cell.configure(keywordModel: keyword, isSelected: isSelected)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 || noticeKeywordList[indexPath.row - 1].keyword == "새 키워드 추가"{
            keywordAddBtnTapPublisher.send()
        }
        else {
            keywordTapPublisher.send(noticeKeywordList[indexPath.row - 1])
        }
    }
}

extension NoticeKeywordCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0 {
            return CGSize(width: 32, height: 32)
        } else {
            let label = UILabel()
            label.text = noticeKeywordList[indexPath.item-1].keyword
            label.font = .appFont(.pretendardBold, size: 14)
            let size = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 34))
            return CGSize(width: size.width + 32, height: 34)
        }
    }
}

