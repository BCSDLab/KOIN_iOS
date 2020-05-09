//
//  CommentRowViewModel.swift
//  Koin
//
//  Created by 정태훈 on 2020/04/06.
//  Copyright © 2020 정태훈. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class CommentRowViewModel<T: CommonComment>: Identifiable {
    private let item: T
    var boardId: Int
    var articleId: Int
    
    init(item: T, boardId: Int, articleId: Int) {
        self.item = item
        self.boardId = boardId
        self.articleId = articleId
    }
    
    func commentDateToString(string_date: String) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormat.date(from: string_date)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let dateString = dateFormatter.string(from: date!)
        return dateString
    }
    
    func blockComment(userId: Int) {
        let userRef = Firestore.firestore().collection("Block").document("\(userId)")
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if (T.self == Comment.self) {
                    userRef.updateData([
                        "Comment": FieldValue.arrayUnion([self.id])
                    ]){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } else {
                    userRef.updateData([
                        "TempComment": FieldValue.arrayUnion([self.id])
                    ]){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            } else {
                if (T.self == Comment.self) {
                    userRef.setData([
                        "Comment": [self.id]
                    ]){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } else {
                    userRef.setData([
                        "TempComment": [self.id]
                    ]){ err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        }
    }
    
    func declarationComment(type: String) {
        Firestore.firestore().collection("Comment").addDocument(data:
            [
                "type": type,
                "board_id": boardId,
                "article_id": articleId,
                "comment_id": id,
                "user_nickname": nickname,
                "comment_content": content
            ]
        )
    }
    
    var id: Int {
        return item.id
    }
    
    var nickname: String {
        return item.nickname
    }
    
    var createAt: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: Date())
        
        return commentDateToString(string_date: item.createdAt ?? dateString)
    }
    
    var content: String {
        return item.content
    }
    
    
}
