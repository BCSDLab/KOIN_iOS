//
//  NoticeAttachmentsTableView.swift
//  koin
//
//  Created by JOOMINKYUNG on 9/15/24.
//

import Combine
import UIKit

final class NoticeAttachmentsTableView: UITableView {
    // MARK: - Properties
    private var subscribtions = Set<AnyCancellable>()
    private var noticeAttachments: [NoticeAttachmentDTO] = []
    let noticeAttachmentTableViewSize = PassthroughSubject<CGFloat, Never>()
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        register(NoticeAttachmentsTableViewCell.self, forCellReuseIdentifier: NoticeAttachmentsTableViewCell.identifier)
        delegate = self
        dataSource = self
        separatorStyle = .none
        showsVerticalScrollIndicator = false
    }
    
    func updateNoticeAttachments(attachments: [NoticeAttachmentDTO]) {
        self.noticeAttachments = attachments
        reloadData()
    }
}

extension NoticeAttachmentsTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeAttachments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoticeAttachmentsTableViewCell.identifier, for: indexPath) as? NoticeAttachmentsTableViewCell
        else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let file = noticeAttachments[indexPath.row].name.extractStringFromParentheses()
        let fileTitle = file.1
        let fileSize = file.0
        cell.configure(attachmentTitle: fileTitle, fileSize: fileSize)
        return cell
    }
    
}

extension NoticeAttachmentsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}



