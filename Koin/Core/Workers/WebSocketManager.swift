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
    private var isConnected: Bool = false // ✅ 연결 상태 체크
    private var subscriptions: Set<String> = [] // ✅ 중복 구독 방지 (Set 사용)

    override init() {
        super.init()
    }
    
    func setUserId(id: Int) {
        self.userId = id
    }
    
    // MARK: - WebSocket 연결
    func connect() {
        guard !isConnected else {
            print("⚠️ WebSocket is already connected")
            return
        }
        
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
        
        // ✅ 이미 구독한 경우 방지
        guard !subscriptions.contains(destination) else {
            print("⚠️ Already subscribed to: \(destination)")
            return
        }
        
        subscriptions.insert(destination)
        socketClient.subscribe(destination: destination)
        print("✅ Subscribed to: \(destination)")
    }
    
    // MARK: - 메시지 보내기
    func sendMessage(roomId: Int, articleId: Int, message: String, isImage: Bool) {
        let destination = "/app/chat/\(articleId)/\(roomId)"
        let payload: [String: Any] = [
            "user_nickname": "익명_\(UUID().uuidString)",
            "user_id": userId,
            "content": message,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "is_image": isImage
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

    // MARK: - WebSocket 연결 해제
    func disconnect() {
        guard isConnected else {
            print("⚠️ WebSocket is already disconnected")
            return
        }
        
        socketClient.disconnect()
        isConnected = false
        print("🔴 WebSocket Disconnected")
    }
}

// MARK: - StompClientLibDelegate (STOMP 메시지 처리)
extension WebSocketManager: StompClientLibDelegate {
    
    // ✅ STOMP 연결 성공 시 호출
    func stompClientDidConnect(client: StompClientLib!) {
        isConnected = true
        print("✅ WebSocket Connected!")
        
        // ✅ 기존 구독 리스트를 기반으로 자동 재구독
        for destination in subscriptions {
            socketClient.subscribe(destination: destination)
            print("🔄 Re-subscribed to: \(destination)")
        }
    }
    
    // 🔴 연결이 끊어졌을 때 자동 재연결
    func stompClientDidDisconnect(client: StompClientLib!) {
        isConnected = false
        print("⚠️ WebSocket Disconnected! Reconnecting...")
        
        // 3초 후 재연결
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.connect()
        }
    }
    
    func stompClientDidReceiveMessage(client: StompClientLib!, jsonBody: AnyObject?, withHeader: [String : String]?, fromDestination: String) {
        if let json = jsonBody as? [String: Any] {
            print("📩 Received Message: \(json)")
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
    
    // 🔄 서버에서 Ping 메시지를 보냈을 때 호출
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
