//
//  BusSearchView.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/23.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


struct BusSearchView: UIViewControllerRepresentable {
    var controller: BusSearchController = UIStoryboard(name: "BusSearch", bundle: nil).instantiateViewController(identifier: "BusSearchController") as! BusSearchController
    
    func makeUIViewController(context: Context) -> BusSearchController {
        return controller
    }
    
    func updateUIViewController(_ uiViewController: BusSearchController, context: Context) {

    }
    
    
    typealias UIViewControllerType = BusSearchController
    
}


class BusSearchController: UIViewController {
    let controller = BusController()
    var currentDate = Date()
    
    @IBOutlet var departButton: UIButton!
    @IBOutlet var arrivalButton: UIButton!
    
    
    @IBOutlet var departView: UIStackView!
    @IBOutlet var arrivalView: UIStackView!
    @IBOutlet var dateView: UIStackView!
    
    @IBOutlet var searchView: UIView!
    
    @IBOutlet var timePicker: UIDatePicker!
    
    @IBOutlet var dateText: UILabel!
    @IBOutlet var timeText: UILabel!
    @IBOutlet var searchButton: UIButton!

    let alert =  UIAlertController(title: "날짜를 설정해주세요", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
    
    @IBOutlet weak var dateButton: UIButton!
    
    let picker: UIDatePicker = UIDatePicker(frame: CGRect(x: 40, y: 40, width: 280, height: 150))
    
    @objc func departAction(_ sender:UITapGestureRecognizer){
       let depart =  UIAlertController(title: "출발지", message: "출발지를 선택해주세요.", preferredStyle: .actionSheet)
       
       let koreatech = UIAlertAction(title: "한기대", style: .default) { (action) in
           self.departButton.setTitle("한기대", for: .normal)
       }
       let terminal = UIAlertAction(title: "야우리", style: .default) { (action) in
           self.departButton.setTitle("야우리", for: .normal)
       }
       
       let station = UIAlertAction(title: "천안역", style: .default) { (action) in
           self.departButton.setTitle("천안역", for: .normal)
       }
       let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
       
       depart.addAction(koreatech)
       depart.addAction(terminal)
       depart.addAction(station)
       depart.addAction(cancel)
       self.present(depart, animated: true, completion: nil)
    }
    
    @objc func arrivalAction(_ sender:UITapGestureRecognizer){
       let arrival =  UIAlertController(title: "도착지", message: "도착지를 선택해주세요.", preferredStyle: .actionSheet)
       
       let koreatech = UIAlertAction(title: "한기대", style: .default) { (action) in
           self.arrivalButton.setTitle("한기대", for: .normal)
       }
       let terminal = UIAlertAction(title: "야우리", style: .default) { (action) in
           self.arrivalButton.setTitle("야우리", for: .normal)
       }
       
       let station = UIAlertAction(title: "천안역", style: .default) { (action) in
           self.arrivalButton.setTitle("천안역", for: .normal)
       }
       let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
       
       arrival.addAction(koreatech)
       arrival.addAction(terminal)
       arrival.addAction(station)
       arrival.addAction(cancel)
       self.present(arrival, animated: true, completion: nil)
    }
    
    @objc func dateAction(_ sender:UITapGestureRecognizer){
            self.present(alert, animated: true, completion: nil)
    }

    @IBAction func searchBusTime(_ sender: UIButton) {
        var depart = "koreatech"
        var arrival = "terminal"
        
        if(self.departButton.title(for: .normal)! == "한기대") {
            depart = "koreatech"
        } else if (self.departButton.title(for: .normal)! == "천안역") {
            depart = "station"
        } else if (self.departButton.title(for: .normal)! == "야우리") {
            depart = "terminal"
        }
        
        if(self.arrivalButton.title(for: .normal)! == "한기대") {
            arrival = "koreatech"
        } else if (self.arrivalButton.title(for: .normal)! == "천안역") {
            arrival = "station"
        } else if (self.arrivalButton.title(for: .normal)! == "야우리") {
            arrival = "terminal"
        }
        
        let search =  UIAlertController(title: "운행정보 조회", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale.current
        let date = dateFormatter.date(from: dateText.text!)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone.autoupdatingCurrent
        timeFormatter.locale = Locale.current
        timeFormatter.dateFormat = "a h시mm분"
        timeFormatter.amSymbol = "오전"
        timeFormatter.pmSymbol = "오후"
        let time = timeFormatter.date(from: timeText.text!)
        
        let calender = Calendar.current
        
        let year = calender.component(.year, from: Date())
        let month = calender.component(.month, from: date!)
        let day = calender.component(.day, from: date!)
        let hour = calender.component(.hour, from: time!)
        let minute = calender.component(.minute, from: time!)
        
        let shuttleTime = self.controller.getNearShuttleTimeToString(depart: depart, arrival: arrival, year: year, month: month, day: day, hour: hour, min: minute)
        let expressTime = self.controller.getNearExpressTimeToString(depart: depart, arrival: arrival, hour: hour, min: minute)
        
        let searchTimeTable = SearchTimeTable(frame: CGRect(x: 25, y: 60, width: 220, height: 80))
        
        searchTimeTable.setTime(shuttle: shuttleTime, express: expressTime)
        search.view.addSubview(searchTimeTable)
        let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
        search.addAction(cancel)
        self.present(search, animated: true, completion: nil)
        
    }
 
    
    @IBAction func selectDate() {
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone.autoupdatingCurrent
        timeFormatter.locale = Locale.current
        timeFormatter.dateFormat = "a h시mm분"
        timeFormatter.amSymbol = "오전"
        timeFormatter.pmSymbol = "오후"
        timeText.text = timeFormatter.string(from: picker.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.locale = Locale.current
         dateFormatter.dateFormat = "yyyy/MM/dd"
        
        let currentDateFormatter = DateFormatter()
        currentDateFormatter.timeZone = TimeZone.autoupdatingCurrent
        currentDateFormatter.locale = Locale.current
         currentDateFormatter.dateFormat = "MMM dd일 EEEE"
        
        
        let departGesture = UITapGestureRecognizer(target: self, action: Selector(("departAction:")))
        let arrivalGesture = UITapGestureRecognizer(target: self, action: Selector(("arrivalAction:")))
        let dateGesture = UITapGestureRecognizer(target: self, action: Selector(("dateAction:")))
        
        self.departView.addGestureRecognizer(departGesture)
        self.arrivalView.addGestureRecognizer(arrivalGesture)
        
        self.dateView.addGestureRecognizer(dateGesture)

        dateButton.setTitle(currentDateFormatter.string(from: Date()), for: .normal)
        
        dateText.text = dateFormatter.string(from: Date())
        
        picker.locale = Locale.current
        departButton.setTitle("한기대", for: .normal)
        
        arrivalButton.setTitle("야우리", for: .normal)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone.autoupdatingCurrent
        timeFormatter.locale = Locale.current
        timeFormatter.dateFormat = "a h시mm분"
        timeFormatter.amSymbol = "오전"
        timeFormatter.pmSymbol = "오후"
        timeText.text = timeFormatter.string(from: currentDate)
        
        timePicker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)
        
        picker.datePickerMode = .date
        picker.date = currentDate
        
        alert.view.addSubview(picker)

        let ok = UIAlertAction(title: "확인", style: .default) { (action) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            dateFormatter.locale = Locale.current
            self.currentDate = self.picker.date
            self.dateText.text = dateFormatter.string(from: self.picker.date)
            self.dateButton.setTitle(currentDateFormatter.string(from: self.picker.date), for: .normal)
        }
        alert.addAction(ok)
        
    }
}


class SearchTimeTable: UIView {
    @IBOutlet var shuttleLabel: UILabel!
    @IBOutlet var expressLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let nib = UINib(nibName: "searchTimeTable", bundle: Bundle.main)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shuttleLabel.text = "00:00"
        expressLabel.text = "00:00"
        self.addSubview(view)
    }
    
    func setTime(shuttle: String, express: String) {
        if shuttle.isEmpty {
            shuttleLabel.text = "없음"
        } else {
            shuttleLabel.text = shuttle
        }
        
        if express.isEmpty {
            expressLabel.text = "없음"
        } else {
            expressLabel.text = express
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
