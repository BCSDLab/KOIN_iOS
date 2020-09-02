//
//  TimeTableViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/08/13.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class TimeTableViewModel: ObservableObject {
    @Published var data: TimeTables = TimeTables(semester: "", timetable: [])
    
    @Published var lectures: Array<Lecture> = []
    
    @Published var detailLecture: Lecture? = nil
    
    @Published var selectedLecture: Lecture? = nil
    
    @Published var query: String = ""
    
    @Published var semesters: Array<Semester> = []
    
    let timeTableFetcher: TimeTableFetcher = TimeTableFetcher()
    
    @Published var semester: String = ""
    
    //@Published var progress: Bool = true
    
    //let objectWillChange = PassthroughSubject<Bool, Never>()
    
    
    private var disposables = Set<AnyCancellable>()

    
    deinit {
        disposables.removeAll()
    }
    
    func load(token: String) {
        //progress = true
        
        self.timeTableFetcher.getTimeTables(semester: semester.isEmpty ? semesters[0].semester : semester, token: token)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { value in
            switch value {
                case .failure:
                    self.data = TimeTables(semester: "", timetable: [])
                case .finished:
                    break
            }
        }, receiveValue: { data in
            self.data = data
            //self.progress = false
        })
            .store(in: &disposables)
    }
    
    func setDetailLecture(lecture: Lecture) {
        self.detailLecture = lecture
    }
    
    func getLectures() {
        //progress = true
        self.timeTableFetcher.getLectures(semester: semester.isEmpty ? semesters[0].semester : semester)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                    case .failure:
                        self.lectures = []
                    case .finished:
                        break
                }
            }, receiveValue: { data in
                self.lectures = data
                //self.progress = false
            })
            .store(in: &disposables)
    }
    
    func getSemester() {
        //progress = true
        self.timeTableFetcher.getSemesters()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                    case .failure:
                        self.semesters = []
                    case .finished:
                        break
                }
            }, receiveValue: { data in
                self.semesters = data
                self.semester = data[0].semester
                //self.progress = false
            })
            .store(in: &disposables)
    }
    
    func addLecture(token: String, lecture: Lecture) {
        //progress = true
        self.timeTableFetcher.addLecture(semester: self.semester, lecture: lecture, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                    case .failure:
                        break
                    case .finished:
                        break
                }
            }, receiveValue: { data in
                self.data = data
                //self.progress = false
            })
            .store(in: &disposables)
    }
    
    func deleteLecture(token: String, lecture: Lecture) {
        //progress = true
        self.timeTableFetcher.deleteLecture(id: (lecture.id)!, token: token)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { value in
                switch value {
                    case .failure:
                    break
                    case .finished:
                        break
                }
            }, receiveValue: { data in
                if(data.success) {
                    var changedTimeTable = self.data.timetable
                    changedTimeTable.removeAll(where: { changeLecture in
                        changeLecture.id == (lecture.id)!
                    })
                    
                    self.data = TimeTables(
                        semester: self.data.semester,
                        timetable: changedTimeTable
                    )
                }
                //self.progress = false
            })
            .store(in: &disposables)
    }
    
    func checkDuplicate(classTime: [Int]) -> (Bool, Int) {
        var totalTime: [Int] = []
        var result: (Bool, Int) = (false, -1)
        
        self.data.timetable.forEach { l in
            totalTime.append(contentsOf: l.classTime)
        }
        
        classTime.forEach { c in
            if(totalTime.contains(c)) {
                result = (true, c)
            }
        }
        
        return result
    }
    
}
