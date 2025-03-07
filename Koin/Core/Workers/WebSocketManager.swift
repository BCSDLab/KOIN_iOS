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
        // Bundle.main.baseUrl는 커스텀 프로퍼티라고 가정 (문자열)
        let rawBaseUrl = Bundle.main.baseUrl
        let baseUrl = rawBaseUrl
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
        let urlString = "wss://\(baseUrl)/ws-stomp"
        guard let url = URL(string: urlString) else {
            fatalError("Invalid WebSocket URL: \(urlString)")
        }
        return url
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSSS" // 서버 기대 포맷
        formatter.timeZone = TimeZone.current // 현재 기기 시간대 사용
        formatter.locale = Locale(identifier: "en_US_POSIX") // 포맷 일관성 유지
        return formatter
    }()
    
    private var isConnected: Bool = false
    private var isManualDisconnect: Bool = false  // 수동 해제 여부 플래그
    private var subscriptions: Set<String> = []     // 중복 구독 방지 (Set 사용)
    
    override init() {
        super.init()
    }
    
    // MARK: - WebSocket 연결
    func connect() {
        guard !isConnected else {
            print("⚠️ WebSocket is already connected")
            return
        }
        isManualDisconnect = false  // 연결 시작 시 수동 해제 플래그 초기화
        let request = URLRequest(url: socketURL)
        let headers = [
            "Authorization": KeychainWorker.shared.read(key: .access) ?? "",
            "accept-version": "1.2,1.1,1.0",
            "heart-beat": "4000,4000"
        ]
        socketClient.openSocketWithURLRequest(request: request as NSURLRequest, delegate: self, connectionHeaders: headers)
    }
    
    // MARK: - WebSocket 구독 (1개의 채팅방만 구독)
    func subscribeToChat(roomId: Int, articleId: Int) {
        let destination = "/topic/chat/\(articleId)/\(roomId)"
        // 이미 구독한 경우가 아니라면 구독 진행
        if subscriptions.contains(destination) {
            print("⚠️ Already subscribed to: \(destination)")
            return
        }
        subscriptions.insert(destination)
        socketClient.subscribe(destination: destination)
        print("✅ Subscribed to: \(destination)")
    }
    
    // MARK: - 구독 해제 (모든 구독 해제)
    private func unsubscribeAll() {
        for destination in subscriptions {
            socketClient.unsubscribe(destination: destination)
            print("✅ Unsubscribed from: \(destination)")
        }
        subscriptions.removeAll()
    }
    
    // MARK: - 메시지 보내기
    func sendMessage(roomId: Int, articleId: Int, message: String, isImage: Bool) {
        let destination = "/app/chat/\(articleId)/\(roomId)"
        let payload: [String: Any] = [
            "user_nickname": UserDataManager.shared.nickname,
            "user_id": UserDataManager.shared.id,
            "content": message,
            "timestamp": dateFormatter.string(from: Date()),
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
    
    // MARK: - WebSocket 연결 해제 (수동 disconnect 시 구독 해제 포함)
    func disconnect() {
        guard isConnected else {
            print("⚠️ WebSocket is already disconnected")
            return
        }
        isManualDisconnect = true  // 사용자가 수동으로 연결 해제했음을 기록
        // 1개의 채팅방만 구독 중이므로 구독 해제
        unsubscribeAll()
        socketClient.disconnect()
        isConnected = false
        print("🔴 WebSocket Disconnected")
    }
}

// MARK: - StompClientLibDelegate (STOMP 메시지 처리)
extension WebSocketManager: StompClientLibDelegate {
    
    // STOMP 메시지를 수신했을 때 (JSON 방식)
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        if let json = jsonBody as? [String: Any] {
            NotificationCenter.default.post(name: .chatMessageReceived, object: nil, userInfo: json)
            print("📩 Received Message: \(json)")
        } else if let body = stringBody {
            print("📩 [Alternative] Received Text Message: \(body) from \(destination)")
        } else {
            print("⚠️ Received an unknown format message from \(destination)")
        }
    }
    
    // STOMP 연결 성공 시 호출
    func stompClientDidConnect(client: StompClientLib) {
        isConnected = true
        print("✅ WebSocket Connected!")
        
        // 기존 구독 리스트 기반으로 재구독 (자동 재연결 시)
        for destination in subscriptions {
            socketClient.subscribe(destination: destination)
            print("🔄 Re-subscribed to: \(destination)")
        }
    }
    
    // 연결이 끊어졌을 때 호출
    func stompClientDidDisconnect(client: StompClientLib) {
        isConnected = false
        print("⚠️ WebSocket Disconnected!")
        
        // 수동 연결 해제가 아니라면 재연결 시도
        if !isManualDisconnect {
            print("Reconnecting in 3 seconds...")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.connect()
            }
        }
    }
    
    // STOMP 메시지를 수신했을 때 (JSON 방식, 추가 콜백)
    func stompClientDidReceiveMessage(client: StompClientLib, jsonBody: Any?, withHeader: [String : String]?, fromDestination: String) {
        if let json = jsonBody as? [String: Any] {
            print("📩 Received Message: \(json)")
            NotificationCenter.default.post(name: .chatMessageReceived, object: nil, userInfo: json)
        } else {
            print("⚠️ Received an unknown message format from \(fromDestination)")
        }
    }
    
    // STOMP 오류 발생 시 호출
    func stompClientDidReceiveError(client: StompClientLib, error: Error) {
        print("❌ STOMP Error: \(error.localizedDescription)")
    }
    
    // 서버로부터 메시지 영수증(Receipt) 수신
    func serverDidSendReceipt(client: StompClientLib, withReceiptId receiptId: String) {
        print("📜 Receipt Received: \(receiptId)")
    }
    
    // 서버에서 오류 메시지를 보냈을 때 호출
    func serverDidSendError(client: StompClientLib, withErrorMessage description: String, detailedErrorMessage message: String?) {
        print("⚠️ Server Error: \(description) | Details: \(message ?? "None")")
    }
    
    // 서버에서 Ping 메시지를 보냈을 때 호출
    func serverDidSendPing() {
        print("🔄 Received Ping from Server")
    }
}
