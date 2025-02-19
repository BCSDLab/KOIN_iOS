//
//  WebSocketManager.swift
//  koin
//
//  Created by 김나훈 on 2/20/25.
//

import UIKit
import StompClientLib

extension Notification.Name {
    static let chatMessageReceived = Notification.Name("chatMessageReceived")
}

final class WebSocketManager: NSObject {
    
    static let shared = WebSocketManager()
    
    private var socketClient = StompClientLib()
    private var socketURL: URL = {
        let baseUrl = Bundle.main.baseUrl.replacingOccurrences(of: "https://", with: "")
                                       .replacingOccurrences(of: "http://", with: "")
        return URL(string: "wss://\(baseUrl)/ws-stomp")!
    }()
    private var userId: Int = 0
    
    // ✅ 여러 채팅방 관리 (roomId, articleId 배열)
    private var subscriptions: [(roomId: Int, articleId: Int)] = []
    
    override init() {
        super.init()
    }
    
    func setUserId(id: Int) {
        self.userId = id
    }
    
    // MARK: - WebSocket 연결
    
    func connect() {
        let request = URLRequest(url: socketURL)
        let headers = [
            "Authorization": KeychainWorker.shared.read(key: .access) ?? "",
            "accept-version": "1.2,1.1,1.0",
            "heart-beat": "4000,4000"
        ]
        
        socketClient.openSocketWithURLRequest(request: request as NSURLRequest, delegate: self, connectionHeaders: headers)
    }
    
    // MARK: - WebSocket 구독 (다중 채팅방)
    func subscribeToChat(roomId: Int, articleId: Int) {
        let destination = "/topic/chat/\(articleId)/\(roomId)"
        
        // ✅ 중복 구독 방지
        if !subscriptions.contains(where: { $0.roomId == roomId && $0.articleId == articleId }) {
            subscriptions.append((roomId, articleId))
        }
        
        socketClient.subscribe(destination: destination)
        print("✅ Subscribed to: \(destination)")
    }
    
    // MARK: - 메시지 보내기 (채팅 메시지 전송)
    func sendMessage(roomId: Int, articleId: Int, message: String) {
        let destination = "/app/chat/\(articleId)/\(roomId)"
        let payload: [String: Any] = [
            "user_nickname": "익명_\(UUID().uuidString)",
            "user_id": userId,
            "content": message,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "is_image": false
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socketClient.sendMessage(
                    message: jsonString,
                    toDestination: destination,
                    withHeaders: ["content-type": "application/json"],
                    withReceipt: ""
                )
                print("📨 Sent Message: \(jsonString)")
            }
        } catch {
            print("❌ JSON Serialization Error: \(error)")
        }
    }

    // MARK: - WebSocket 연결 해제 (재구독을 위해 기존 구독 정보 유지)
    func disconnect() {
        socketClient.disconnect()
        print("🔴 WebSocket Disconnected")
    }
}

// MARK: - StompClientLibDelegate (STOMP 메시지 처리)
extension WebSocketManager: StompClientLibDelegate {
    
    // ✅ STOMP 연결 성공 시 호출
    func stompClientDidConnect(client: StompClientLib!) {
            print("✅ WebSocket Connected!")
            
            // ✅ 기존 구독 리스트를 기반으로 재구독
            for (roomId, articleId) in subscriptions {
                subscribeToChat(roomId: roomId, articleId: articleId)
            }
        }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        connect()
       }
    
    func stompClientDidReceiveMessage(client: StompClientLib!, jsonBody: AnyObject?, withHeader: [String : String]?, fromDestination: String) {
           if let json = jsonBody as? [String: Any] {
               print("📩 Received Message: \(json)")
               
               // ✅ 여러 화면에서 받을 수 있도록 NotificationCenter로 이벤트 전송
               NotificationCenter.default.post(name: .chatMessageReceived, object: nil, userInfo: json)
           } else {
               print("⚠️ Received an unknown message format from \(fromDestination)")
           }
       }
    
    // ❌ STOMP 오류 발생 시 호출
    func stompClientDidReceiveError(client: StompClientLib!, error: NSError!) {
        print("❌ STOMP Error: \(error.localizedDescription)")
    }
    
    // 📜 서버로부터 메시지 영수증(Receipt) 수신
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("📜 Receipt Received: \(receiptId)")
    }
    
    // ⚠️ 서버에서 오류 메시지를 보냈을 때 호출
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("⚠️ Server Error: \(description) | Details: \(message ?? "None")")
    }
    
    // 🔄 서버에서 Ping 메시지 보냈을 때 호출
    func serverDidSendPing() {
        print("🔄 Received Ping from Server")
    }
    
    // 📩 STOMP 메시지를 수신했을 때 호출 (추가적인 콜백)
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        if let json = jsonBody as? [String: Any] {
            NotificationCenter.default.post(name: .chatMessageReceived, object: nil, userInfo: json)
        } else if let body = stringBody {
            print("📩 [Alternative] Received Text Message: \(body) from \(destination)")
        } else {
            print("⚠️ Received an unknown format message from \(destination)")
        }
    }
}
