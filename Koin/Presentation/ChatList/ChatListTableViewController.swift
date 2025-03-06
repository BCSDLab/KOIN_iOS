//
//  ChatListTableViewController.swift
//  koin
//
//  Created by 김나훈 on 2/18/25.
//

import Combine
import UIKit

final class ChatListTableViewController: UITableViewController {
    
    // MARK: - Properties
    private let viewModel: ChatListTableViewModel
    private let inputSubject: PassthroughSubject<ChatListTableViewModel.Input, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    
    
    init(viewModel: ChatListTableViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = "쪽지"
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
     }
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bind()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivedMessage(_:)), name: .chatMessageReceived, object: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        inputSubject.send(.fetchChatRooms)
        configureNavigationBar(style: .empty)
    }
    
    // MARK: - Bind
    
    private func bind() {
        let outputSubject = viewModel.transform(with: inputSubject.eraseToAnyPublisher())
        
        outputSubject.receive(on: DispatchQueue.main).sink { [weak self] output in
            guard let strongSelf = self else { return }
            switch output {
            case .showChatRoom:
                self?.tableView.reloadData()
            }
        }.store(in: &subscriptions)
    }
}

extension ChatListTableViewController {
    
    @objc private func handleReceivedMessage(_ notification: Notification) {
                inputSubject.send(.fetchChatRooms)
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = viewModel.chatList[indexPath.row]
        let viewController = ChatViewController(viewModel: ChatViewModel(articleId: chat.articleId, chatRoomId: chat.chatRoomId, articleTitle: chat.articleTitle))
        inputSubject.send(.logEvent(EventParameter.EventLabel.Campus.messageListSelect, .click, "쪽지"))
        navigationController?.pushViewController(viewController, animated: true)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        let chat = viewModel.chatList[indexPath.row]
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let thumbnailContainerView = UIView().then {
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.backgroundColor = UIColor.appColor(.neutral50)
            $0.layer.borderWidth = 1.0
            $0.layer.borderColor = UIColor.appColor(.neutral200).cgColor
        }
        let thumbnailImageView = UIImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
        let titleLabel = UILabel().then {
            $0.font = UIFont.appFont(.pretendardMedium, size: 16)
            $0.textColor = UIColor.appColor(.neutral800)
        }
        let contentLabel = UILabel().then {
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
        }
        let recentTimeLabel = UILabel().then {
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.textColor = UIColor.appColor(.neutral500)
            $0.textAlignment = .right
        }
        let unreadMessageLabel = UILabel().then {
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.backgroundColor = UIColor.appColor(.primary500)
            $0.textColor = UIColor.appColor(.neutral0)
            $0.textAlignment = .center
            $0.font = UIFont.appFont(.pretendardMedium, size: 12)
        }
        thumbnailContainerView.addSubview(thumbnailImageView)
        if let url = chat.lostItemImageUrl {
            thumbnailImageView.loadImageWithSpinner(from: url)
            thumbnailImageView.snp.remakeConstraints { make in
                make.centerY.centerX.equalToSuperview()
                make.width.height.equalTo(48)
            }
        } else {
            thumbnailImageView.image = UIImage.appImage(asset: .basicPicture)
            thumbnailImageView.snp.remakeConstraints { make in
                make.centerY.centerX.equalToSuperview()
                make.width.height.equalTo(32)
            }
        }
        titleLabel.text = chat.articleTitle
        contentLabel.text = "\(chat.recentMessageContent)"
        recentTimeLabel.text = chat.lastMessageAt.toChatDateInfo().showingText
        unreadMessageLabel.text = String(chat.unreadMessageCount)
        unreadMessageLabel.isHidden = chat.unreadMessageCount == 0
        
        [thumbnailContainerView, recentTimeLabel, titleLabel, contentLabel, unreadMessageLabel].forEach {
            cell.contentView.addSubview($0)
        }
        thumbnailContainerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(48)
        }
        thumbnailImageView.snp.remakeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.width.height.equalTo(32)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailContainerView.snp.top).offset(3)
            $0.leading.equalTo(thumbnailContainerView.snp.trailing).offset(12)
            $0.height.equalTo(22)
            $0.trailing.equalTo(recentTimeLabel.snp.leading).offset(-5)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalTo(titleLabel)
            $0.height.equalTo(20)
            $0.trailing.equalTo(unreadMessageLabel.snp.leading).offset(-5)
        }
        recentTimeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(19)
        }
        unreadMessageLabel.snp.makeConstraints {
            $0.top.equalTo(recentTimeLabel.snp.bottom)
            $0.height.equalTo(20)
            $0.width.equalTo(unreadMessageLabel.intrinsicContentSize.width + 12)
            $0.trailing.equalTo(recentTimeLabel)
        }
        DispatchQueue.main.async {
            unreadMessageLabel.layer.cornerRadius = unreadMessageLabel.frame.height / 2
        }
        return cell
    }
    
}

extension ChatListTableViewController {
    
    private func setUpLayOuts() {
        [].forEach {
            view.addSubview($0)
        }
        
    }
    
    private func setUpConstraints() {
    }
    
    private func configureView() {
        setUpLayOuts()
        setUpConstraints()
        self.view.backgroundColor = .systemBackground
    }
}
