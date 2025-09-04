##   Koin - 한기대 학생들의 필수 앱 (KoreaTech IN)

<img src="https://github.com/user-attachments/assets/75742ede-7e33-435c-9330-c9b6ab232231" width="200"/>

> [!IMPORTANT]   
> 한국기술교육대학교의 학식, 주변 식당, 버스, 시간표, 공지사항 등 필수 정보를 제공하는   
> DAU 1,100, MAU 3,000명 이상 커뮤니티 서비스 앱으로, 재학생의 60% 이상이 사용하고 있습니다.   

> 여러 직무의 팀원들과 각자 전문성을 살려 프로덕트를 개발하고 있습니다.   
> (BackEnd / FrontEnd / Android / iOS / Design / DA / PM / Security)

---

### ⚙️ Tech Stack

### 🎨 UI
- UIKit
  - iOS 기본 UI 프레임워크. 탭/네비게이션, 셀, 커스텀 전환 등 핵심 화면 구성에 사용.  
- Code-based AutoLayout 
  - 스토리보드 미사용, 코드 제약 기반. 변경·리뷰·머지 용이, 환경별 레이아웃 제어 쉬움.  
- SnapKit  
  - AutoLayout DSL로 제약을 간결하게 선언. 리스트/디테일/설정 화면 레이아웃 전반에 적용.  
### 🏛️ 디자인 패턴
- MVVM & Clean Architecture
  - UI(View) / 비즈니스 로직(ViewModel) / 데이터 계층(Model) 분리.  
  - 의존성 역전을 통해 유지보수성과 테스트 용이성 확보.
  - Presentation, Domain, Data 영역으로 구분
### 📦 의존성 관리
- CocoaPods  
  - WebSocket-Stomp, Alamofire 등 서드파티 라이브러리 관리.  
### 🧩 기타 ( Data / Reactive )
- WebSocket + STOMP
  - 실시간 스트림(채팅 기능) 수신. 서버와 양방향 메시징 채널 유지.  
- Core Data 
  - 오프라인 캐시/영속성. 학식/버스/공지 리스트 로컬 저장, 앱 재시작 시 빠른 부팅 지원 및 비로그인 지원 
- Combine 
  - 비동기 스트림 & 네트워크 처리.
- Kingfisher  
  - 비동기 이미지 로딩 및 캐싱. 학식/공지 등 서버 이미지 리소스를 효율적으로 다운로드 & 재사용.  
- WebKit  
  - 단순 웹뷰 표시뿐 아니라 JavaScript ↔ Swift 양방향 메시지 처리를 통해 이벤트를 보내고 받으며,  
    학사 공지, 인증, 외부 시스템 연동 등 상호작용이 필요한 화면에 사용.  

### ☀️ 주요 기능
<table>
  <tr>
    <td align="center" width="180">
      <b>버스 화면</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/b7f3325e-a780-4823-a5f4-fbce9058271b" width="160"/><br/>
      <p style="font-size:12px;">실시간 버스 도착 및 운행 정보를 제공합니다.</p>
    </td>
    <td align="center" width="180">
      <b>분실물 화면</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/dc86461c-af39-4ebc-a40d-e641bf2b815c" width="160"/><br/>
      <p style="font-size:12px;">분실물을 등록하여 쉽게 찾을 수 있습니다.</p>
    </td>
    <td align="center" width="180">
      <b>학교 식단</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/98411676-03b5-43da-b4bb-3b3d84ccb610" width="160"/><br/>
      <p style="font-size:12px;">오늘의 학식 메뉴를 간편하게 확인하세요.</p>
    </td>
    <td align="center" width="180">
      <b>식당 리뷰</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/64749b6a-7c92-4111-b46f-88a6923ad653" width="160"/><br/>
      <p style="font-size:12px;">학교 주변 식당의 리뷰와 평점을 공유합니다.</p>
    </td>
    <td align="center" width="180">
      <b>채팅 기능</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/7d654fdd-cda8-416d-9e4c-1a85644da8ac" width="160"/><br/>
      <p style="font-size:12px;">학생들 간 실시간 소통을 지원합니다.</p>
    </td>
  </tr>
  <tr>
    <td align="center" width="180">
      <b>시간표 기능</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/f8eff239-f622-44bf-9787-15fd432a13a4" width="160"/><br/>
      <p style="font-size:12px;">내 강의 시간표를 편리하게 관리할 수 있습니다.</p>
    </td>
    <td align="center" width="180">
      <b>강제 업데이트</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/ea99fe47-302e-4148-b848-05ed40f7783a" width="160"/><br/>
      <p style="font-size:12px;">필수 업데이트 시 강제 업데이트를 안내합니다.</p>
    </td>
    <td align="center" width="180">
      <b>주변 식당</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/6ae93867-5450-4e3b-aa44-1863aa433c2f" width="160"/><br/>
      <p style="font-size:12px;">학교 주변 식당 메뉴와 위치를 제공합니다.</p>
    </td>
    <td align="center" width="180">
      <b>복덕방</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/8e3729c2-e698-48d3-9655-44450524ee29" width="160"/><br/>
      <p style="font-size:12px;">자취방 및 원룸 정보를 공유합니다.</p>
    </td>
    <td align="center" width="180">
      <b>푸시 알림 & 딥링크</b><br/>
      ───<br/>
      <img src="https://github.com/user-attachments/assets/848e6441-0b9c-4052-b0dc-b77c2aca242b" width="160"/><br/>
      <p style="font-size:12px;">알림을 눌러 딥링크로 바로 이동합니다.</p>
    </td>
  </tr>
</table>

### 🗂️ Package Structure
```
Koin
├── Domain                          # 핵심 비즈니스 로직 계층
│   ├── Repository                  # 추상화된 저장소 인터페이스
│   ├── Model                       # 엔티티, 비즈니스 모델
│   └── UseCase                     # 도메인 규칙/유즈케이스
│
├── Data                            # 데이터 계층 (Infra)
│   ├── DTOs                        # 데이터 전송 객체
│   │   ├── Encodable
│   │   └── Decodable
│   ├── MockService                 # 테스트용 Mock 서비스
│   ├── Service                     # 네트워크/외부 API 연동
│   └── Repository                  # 실제 구현체 (Domain Repository 구현)
│
├── Presentation                    # 프레젠테이션 계층 (UI)
│   ├── View                        # UIKit View, ViewController
│   └── ViewModel                   # MVVM ViewModel
│
├── Resources                       # 리소스 모음
│   ├── Gif
│   ├── Assets
│   └── Fonts
│
├── Core                            # 공통 유틸리티 & 시스템 계층
│   ├── CoreData                    # Core Data 스택 및 관리 코드
│   ├── Workers                     # 싱글톤 패턴 Worker
│   ├── Extensions                  # Swift Extensions
│   ├── View                        # 공통 UI 컴포넌트
│   ├── Logger                      # 로깅 모듈
│   └── Protocol                    # 공용 프로토콜 정의
│
├── Apps                            # 엔트리포인트 (AppDelegate 등)
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── NotificationHandler.swift
│
├── NotificationService             # 알림 확장 서비스
│
├── koinUITests                     # UI 테스트 모듈
│   ├── koinUITests.swift
│   └── koinUITestsLaunchTests.swift
│
├── Products                        # Xcode 기본 Products
├── Pods                            # CocoaPods 종속성
└── Frameworks                      # 외부 프레임워크
```

---

### 🧑‍🧑‍🧒‍🧒 Team Members

| <img src="https://avatars.githubusercontent.com/u/118811606?v=4" width="130"> | <img src="https://avatars.githubusercontent.com/u/74389635?v=4" width="130"> | <img src="https://avatars.githubusercontent.com/u/139556438?v=4" width="130"> | <img src="https://avatars.githubusercontent.com/u/183201303?v=4" width="130"> | <img src="https://avatars.githubusercontent.com/u/202774410?v=4" width="130"> |
| :--: | :--: | :--: | :--: | :--: |
| [나훈](https://github.com/KimNahun) | [민경](https://github.com/Ju-Min-Kyung) | [은지](https://github.com/oeunji) | [기정](https://github.com/hgjwilly-koreatech) | [성민](https://github.com/xp65241) |
| 2024.3 ~ 2025.5 | 2024.4 ~ 2024.12 | 2025.3 ~ ing | 2025.9 ~ ing | 2025.9 ~ ing |
   
--- 

> [!TIP]   
> #### BCSD 동아리 정보와 App 설치는 아래에서 확인할 수 있습니다.   
> 📝 [BCSD 블로그](https://blog.bcsdlab.com/introduce)   
> 🤖 [Koin App(Android) 설치하기](https://play.google.com/store/apps/details?id=in.koreatech.koin&hl=ko)   
> 🍎 [Koin App(IOS) 설치하기](https://apps.apple.com/bh/app/%EC%BD%94%EC%9D%B8-koreatech-in-%ED%95%9C%EA%B8%B0%EB%8C%80-%EC%BB%A4%EB%AE%A4%EB%8B%88%ED%8B%B0/id1500848622)   
> 👉 [Koin Web 바로가기](https://koreatech.in/)
