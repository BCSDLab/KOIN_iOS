//
//  CallVanReportRequestDto.swift
//  koin
//
//  Created by 홍기정 on 3/10/26.
//

import Foundation

struct CallVanReportRequestDto: Encodable {
    let reportedUserId: Int
    let reasons: [CallVanReportRequestReasonDto]
    let description: String?
    let attachments: [CallVanReportRequestAttachmentDto]

    enum CodingKeys: String, CodingKey {
        case reportedUserId = "reported_user_id"
        case reasons, description, attachments
    }
}


struct CallVanReportRequestReasonDto: Encodable {
    var reasonCode: CallVanReportRequestReasonCodeDto
    var customReason: String?

    enum CodingKeys: String, CodingKey {
        case reasonCode = "reason_code"
        case customReason = "custom_text"
    }
}

enum CallVanReportRequestReasonCodeDto: String, Encodable {
    case noShow = "NO_SHOW"
    case nonPayment = "NON_PAYMENT"
    case profanity = "PROFANITY"
    case other = "OTHER"
}

extension CallVanReportRequestDto {
    
    init(from model: CallVanReportRequest) {
        self.reportedUserId = model.reportedUserId
        self.reasons = model.reasons.map { CallVanReportRequestReasonDto(from: $0) }
        self.description = model.descriptions
        self.attachments = model.imageUrls.compactMap {
            CallVanReportRequestAttachmentDto(attachmentType: "IMAGE", url: $0)
        }
    }
}

extension CallVanReportRequestReasonDto {
    
    init(from model: CallVanReportRequestReason) {
        self.reasonCode = CallVanReportRequestReasonCodeDto(from: model.reasonCode)
        self.customReason = model.customReason
    }
}

extension CallVanReportRequestReasonCodeDto {
    
    init(from model: CallVanReportRequestReasonCode) {
        switch model {
        case .noShow:
            self = .noShow
        case .nonPayment:
            self = .nonPayment
        case .profanity:
            self = .profanity
        case .other:
            self = .other
        }
    }
}

struct CallVanReportRequestAttachmentDto: Encodable {
    let attachmentType: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case attachmentType = "attachment_type"
        case url
    }
}
