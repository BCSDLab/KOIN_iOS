//
//  AddDirectCollectionView.swift
//  koin
//
//  Created by 김나훈 on 11/20/24.
//

import Combine
import UIKit

struct Schedule {
    let name: String
    let times: [String] // 예: ["301", "103"] (목요일 9시, 월요일 10시)
}

final class AddDirectCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var somethings: [Int] = []
    let completeButtonPublisher = PassthroughSubject<(String, [Int]), Never>()
    let addDirectButtonPublisher = PassthroughSubject<Void, Never>()
    let addClassButtonPublisher = PassthroughSubject<Void, Never>()
    let didTapCellPublisher = PassthroughSubject<Void, Never>()
    let filterButtonPublisher = PassthroughSubject<Void, Never>()
    private var headerCancellables = Set<AnyCancellable>()
    private var footerCancellables = Set<AnyCancellable>()
    private var headerView: AddDirectHeaderView?
    
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionHeadersPinToVisibleBounds = true
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
        isScrollEnabled = true
        register(AddDirectCollectionViewCell.self, forCellWithReuseIdentifier: AddDirectCollectionViewCell.identifier)
        register(AddDirectHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: AddDirectHeaderView.identifier)
        register(AddDirectFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: AddDirectFooterView.identifier)
        dataSource = self
        delegate = self
    }
    
    func setUpSomethings() {
        
        reloadData()
    }
    func collectSchedules() -> Schedule? {
        guard let headerView = headerView else {
            return nil
        }
        
        let scheduleName = headerView.calendarView.textValue
        if scheduleName.isEmpty {
            return nil
        }
        
        // 헤더에서 요일, 시작 시간, 종료 시간 가져오기
        let headerDay = headerView.selectTimeView.selectedDay
        let headerStartTime = headerView.selectTimeView.selectedTime // 시작 시간
        let headerEndTime = headerView.selectTimeView.endedTime        // 종료 시간
        
        guard let headerDayIndex = ["월", "화", "수", "목", "금"].firstIndex(of: String(headerDay.prefix(1))) else {
            return nil
        }
        
        let headerDayCode = "\(headerDayIndex)"
        let headerTimeCodes = generateTimeRangeCodes(from: headerStartTime, to: headerEndTime).map { "\(headerDayCode)\($0)" }
        
        // 셀의 시간 정보 수집
        var cellTimes: [String] = []
        for index in 0..<somethings.count {
            let indexPath = IndexPath(item: index, section: 0)
            guard let cell = cellForItem(at: indexPath) as? AddDirectCollectionViewCell else {
                continue
            }
            
            let cellDay = cell.selectTimeView.selectedDay
            let cellStartTime = cell.selectTimeView.selectedTime // 시작 시간
            let cellEndTime = cell.selectTimeView.endedTime        // 종료 시간
            
            guard let cellDayIndex = ["월", "화", "수", "목", "금"].firstIndex(of: String(cellDay.prefix(1))) else {
                continue
            }
            
            let cellDayCode = "\(cellDayIndex)"
            let cellTimeCodes = generateTimeRangeCodes(from: cellStartTime, to: cellEndTime).map { "\(cellDayCode)\($0)" }
            cellTimes.append(contentsOf: cellTimeCodes)
        }
        
        // 헤더와 셀의 데이터를 합침
        let allTimes = headerTimeCodes + cellTimes
        
        if allTimes.isEmpty {
            return nil
        }
        
        return Schedule(name: scheduleName, times: allTimes)
    }
    
    private func generateTimeRangeCodes(from startTime: String, to endTime: String) -> [String] {
        guard let startComponents = parseTime(startTime),
              let endComponents = parseTime(endTime) else { return [] }
        
        var currentHour = startComponents.hour
        var currentMinute = startComponents.minute
        let endHour = endComponents.hour
        let endMinute = endComponents.minute
        
        var codes: [String] = []
        
        while (currentHour < endHour) || (currentHour == endHour && currentMinute < endMinute) {
            let code = generateTimeCode(hour: currentHour, minute: currentMinute)
            codes.append(code)
            
            // 30분 단위 증가
            currentMinute += 30
            if currentMinute >= 60 {
                currentMinute = 0
                currentHour += 1
            }
        }
        
        return codes
    }
    
    private func parseTime(_ time: String) -> (hour: Int, minute: Int)? {
        let components = time.split(separator: ":").map { Int($0) ?? 0 }
        guard components.count == 2 else { return nil }
        return (hour: components[0], minute: components[1])
    }
    
    private func generateTimeCode(hour: Int, minute: Int) -> String {
        let hourCode = hour - 9 // 시작 시간 기준 9시
        let minuteCode = minute / 30
        let code = hourCode * 2 + minuteCode
        return String(format: "%02d", code)
    }
    
    
    // 완료 버튼 눌렀을 때 데이터 취합
    func completeButtonTapped() {
        
        if let schedule = collectSchedules() {
            print(schedule.times)
            completeButtonPublisher.send((schedule.name, schedule.times.map { Int($0) ?? 0} ) )
        }
    }
}

extension AddDirectCollectionView {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 119)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return somethings.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 240)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 48, height: 35)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddDirectHeaderView.identifier, for: indexPath) as? AddDirectHeaderView else {
                return UICollectionReusableView()
            }
            headerCancellables.removeAll()
            self.headerView = headerView
            headerView.classButtonPublisher.sink { [weak self] in
                self?.addClassButtonPublisher.send()
            }.store(in: &headerCancellables)
            headerView.completeButtonPublisher.sink { [weak self] in
                self?.completeButtonTapped()
            }.store(in: &headerCancellables)
            return headerView
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: AddDirectFooterView.identifier, for: indexPath) as? AddDirectFooterView else {
                return UICollectionReusableView()
            }
            footerCancellables.removeAll()
            footerView.footerTapPublisher.sink { [weak self] in
                self?.somethings.append(1)
                self?.reloadData()
            }.store(in: &footerCancellables)
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddDirectCollectionViewCell.identifier, for: indexPath) as? AddDirectCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(text: String(somethings[indexPath.row]))
        
        cell.deleteButtonPublisher.sink { [weak self] _ in
            
            self?.somethings.remove(at: indexPath.row)
            self?.reloadData()
        }.store(in: &cell.cancellables)
        return cell
    }
}
