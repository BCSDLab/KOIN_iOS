//
//  DepartmentCategoryDto.swift
//  koin
//
//  Created by 홍기정 on 7/21/26.
//

import Foundation

struct DepartmentCategoriesDto: Decodable {
    let updatedAt: String
    let categories: [DepartmentCategoryDto]
    
    private var displayUpdatedAt: String? {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [
            .withYear,
            .withMonth,
            .withDay,
            .withDashSeparatorInDate,
            .withTime,
            .withColonSeparatorInTime
        ]
        
        if let date = inputFormatter.date(from: updatedAt) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy.MM.dd"
            return outputFormatter.string(from: date)
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case categories
    }
    
    func toDomain() -> (departments: [Department], updatedAt: String) {
        let departments = categories
            .reduce([DepartmentDto]()) { departments, category in
                departments + category.departments
            }.compactMap {
                $0.toDomain()
            }
        return (departments, displayUpdatedAt ?? "")
    }
}

struct DepartmentCategoryDto: Decodable {
    let updatedAt: String?
    let category: String
    let categoryName: String
    let departments: [DepartmentDto]
    
    private var displayUpdatedAt: String? {
        guard let updatedAt else { return nil}
        
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [
            .withYear,
            .withMonth,
            .withDay,
            .withDashSeparatorInDate,
            .withTime,
            .withColonSeparatorInTime
        ]
        
        if let date = inputFormatter.date(from: updatedAt) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy.MM.dd"
            return outputFormatter.string(from: date)
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case category
        case categoryName = "category_name"
        case departments
    }
    
    func toDomain() -> DepartmentCategory? {
        DepartmentCategory(rawValue: category)
    }
    
    func toDomain() -> (departments: [Department], updatedAt: String) {
        return (
            departments.map { $0.toDomain() },
            displayUpdatedAt ?? ""
        )
    }
}

struct DepartmentDto: Decodable {
    let name: String
    let isSingleContact: Bool
    let contacts: [DepartmentTaskDto]

    enum CodingKeys: String, CodingKey {
        case name
        case isSingleContact = "is_single_contact"
        case contacts
    }
    
    func toDomain() -> Department {
        Department(
            id: name.hashValue,
            name: name,
            tasks: contacts.map {
                $0.toDomain()
            }
        )
    }
}

struct DepartmentTaskDto: Decodable {
    let task, phoneNumber: String

    enum CodingKeys: String, CodingKey {
        case task
        case phoneNumber = "phone_number"
    }
    
    func toDomain() -> DepartmentTask {
        DepartmentTask(
            id: task.hashValue,
            name: task,
            phoneNumber: phoneNumber
        )
    }
}
