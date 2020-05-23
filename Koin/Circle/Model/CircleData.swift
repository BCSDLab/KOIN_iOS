//
//  Circles.swift
//  Koin
//
//  Created by 정태훈 on 2020/05/09.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation

struct Circles: Codable {
    let totalPage: Int
    let totalItemCount: Int
    let circles: [CircleData]
}

struct CircleData: Codable  {
    let background_img_url: String?
    let category: String
    let id: Int
    let introduce_url: String?
    let line_description: String
    let location: String?
    let logo_url: String?
    let major_business: String?
    let name: String
    let professor: String?
}

struct CircleDetail: Codable {
    let background_img_url: String?
    let category: String
    let id: Int
    let introduce_url: String?
    let line_description: String
    let description: String
    let link_urls: [Link]?
    let location: String?
    let logo_url: String?
    let major_business: String?
    let name: String
    let professor: String?
    let faq: FAQ?
}

struct Link: Codable {
    let type: String
    let link: String
}

struct FAQ: Codable {
    let totalPage: Int
    let totalItemCount: Int
    let items: [QnA]?
}

struct QnA: Codable {
    let answer: String
    let circle_id: Int
    let id: Int
    let question: String
}
