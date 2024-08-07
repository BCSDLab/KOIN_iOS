//
//  CollectionViewDelegate.swift
//  Koin
//
//  Created by 김나훈 on 3/13/24.
//

import Foundation
// FIXME: 지우기

// 컬렉션뷰 등의 상세 View에서 ViewController로 이벤트를 전송하기 위해 사용했으나
// 어떤 곳에서는 Combine을 쓰고, 어떤 곳에서는 delegate를 사용해서
// Combine으로 통합해야함
protocol CollectionViewDelegate: AnyObject {
    func didTapCell(at id: Int)
}
