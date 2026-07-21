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
        return (departments, updatedAt)
    }
}

struct DepartmentCategoryDto: Decodable {
    let updatedAt: String?
    let category: String
    let categoryName: String
    let departments: [DepartmentDto]

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
        return (departments.map { $0.toDomain() }, updatedAt ?? "")
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


//struct CategoriesDto: Decodable {
//    let updatedAt: String
//    let categories: [CategoryDto]
//
//    enum CodingKeys: String, CodingKey {
//        case updatedAt = "updated_at"
//        case category
//        case categoryName = "category_name"
//        case departments
//    }
//}
//
//struct DepartmentDto: Decodable {
//    let name: String
//    let isSingleContact: Bool
//    let contacts: [DepartmentTaskDto]
//
//    enum CodingKeys: String, CodingKey {
//        case name
//        case isSingleContact = "is_single_contact"
//        case contacts
//    }
//}
//
//struct DepartmentTaskDto: Decodable {
//    let task: String
//    let phoneNumber: String
//
//    enum CodingKeys: String, CodingKey {
//        case task
//        case phoneNumber = "phone_number"
//    }
//}
//
//extension DepartmentCategoryDto {
//    func toDomain() -> (departments: [Department], updatedAt: String) {
//        return (
//            departments: departments.map { $0.toDomain() },
//            updatedAt: updatedAt
//        )
//    }
//}
//
//extension DepartmentDto {
//    func toDomain() -> Department {
//        Department.init(
//            id: name.hashValue,
//            name: name,
//            tasks: contacts.map { $0.toDomain(departmentName: name) }
//        )
//    }
//}
//
//extension DepartmentTaskDto {
//    func toDomain(departmentName: String) -> DepartmentTask {
//        DepartmentTask.init(
//            id: (departmentName + task + phoneNumber).hashValue,
//            name: task,
//            phoneNumber: phoneNumber
//        )
//    }
//}
