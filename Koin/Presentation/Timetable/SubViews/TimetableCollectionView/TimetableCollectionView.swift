////
////  TimeTableCollectionView.swift
////  koin
////
////  Created by 김나훈 on 3/30/24.
////
//
//import Combine
//import SnapKit
//import UIKit
//
//final class TimetableCollectionView: UICollectionView, UICollectionViewDataSource {
//    
//    private var tableList: [(String, String)] = []
//    var cellTapPublisher = PassthroughSubject<Int, Never>()
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
//        generateTimeTable()
//        register(TimetableCollectionViewCell.self, forCellWithReuseIdentifier: TimetableCollectionViewCell.identifier)
//        dataSource = self
//    }
//}
//
//extension TimetableCollectionView {
//    func canAddLecture(at classTimes: [Int]) -> Bool {
//        for time in classTimes {
//            let dayOfWeekIndex = time / 100
//            let classPeriod = time % 100
//
//            let indexPath = IndexPath(item: classPeriod, section: 0)
//            guard let cell = cellForItem(at: indexPath) as? TimetableCollectionViewCell else { continue }
//
//            if cell.cellId[dayOfWeekIndex] != nil {
//                return false
//            }
//        }
//
//        return true
//    }
//
//
//
//
//    func updatetimetables(_ table: TimetablesDTO) {
//       removeAllCellsInfo()
//        table.timetable.forEach { timetable in
//            let randomColor = UIColor.randomLightColor()
//            timetable.classTime.forEach { time in
//                let cellPosition = time % 100
//                let indexPath = IndexPath(item: cellPosition, section: 0)
//                let timeString = String(time)
//                let labelIndex: Int
//                let isFirstElement = time == timetable.classTime.first
//                if timeString.count >= 3, let firstChar = timeString.first, let firstNum = Int(String(firstChar)) {
//                    labelIndex = firstNum
//                } else {
//                    labelIndex = 0
//                }
//                if let cell = self.cellForItem(at: indexPath) as? TimetableCollectionViewCell {
//                    cell.updateText(text: isFirstElement ? timetable.classTitle : nil, index: labelIndex, color: randomColor, id: timetable.id)
//                }
//            }
//        }
//    }
//    
//    // FIXME: 이거 삭제할때 같은 행에 여러 수업있으면 첫번쨰거만 삭제된거로 표시됨 .반영하기
//    func removeCellsInfoById(_ id: Int) {
//        for section in 0..<self.numberOfSections {
//            for item in 0..<self.numberOfItems(inSection: section) {
//                let indexPath = IndexPath(item: item, section: section)
//                if let cell = self.cellForItem(at: indexPath) as? TimetableCollectionViewCell, cell.cellId.contains(id) {
//                    cell.removeInfoById(id)
//                }
//            }
//        }
//    }
//    
//    func removeAllCellsInfo() {
//        for section in 0..<self.numberOfSections {
//            for item in 0..<self.numberOfItems(inSection: section) {
//                let indexPath = IndexPath(item: item, section: section)
//                if let cell = self.cellForItem(at: indexPath) as? TimetableCollectionViewCell {
//                    cell.removeCellInfo()
//                }
//            }
//        }
//    }
//    
//    private func generateTimeTable() {
//        let prefixes = (1...15).map { String(format: "%02d", $0) }
//        let suffixes = ["A", "B"]
//        let startHour = 9
//        tableList.removeAll()
//        
//        var currentHour = startHour
//        var currentMinute = 0
//        
//        for prefix in prefixes {
//            for suffix in suffixes {
//                let time = String(format: "%02d:%02d", currentHour, currentMinute)
//                tableList.append((prefix + suffix, time))
//                currentMinute += 30
//                if currentMinute >= 60 {
//                    currentHour += 1
//                    currentMinute = 0
//                }
//                if currentHour == 23 && currentMinute > 30 {
//                    break
//                }
//            }
//        }
//    }
//}
//
//extension TimetableCollectionView {
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return tableList.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimetableCollectionViewCell.identifier, for: indexPath) as? TimetableCollectionViewCell else {
//            return UICollectionViewCell()
//        }
//        let landItem = tableList[indexPath.row]
//        let isBorder = indexPath.row % 2 == 0
//        cell.configure(info: landItem, isBorder: isBorder)
//        cell.onTap = { [weak self] cellId in
//            self?.cellTapPublisher.send(cellId)
//        }
//        return cell
//    }
//    
//}
