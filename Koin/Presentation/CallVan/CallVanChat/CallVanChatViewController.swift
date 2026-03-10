//
//  CallVanChatViewController.swift
//  koin
//
//  Created by 홍기정 on 3/9/26.
//

import UIKit
import Combine
import SnapKit
import Then

final class CallVanChatViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: CallVanChatViewModel
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - UI Components
    private let callVanChatTableView = CallVanChatTableView()
    private let wrapperView = UIView()
    private let sendImageButton = UIButton()
    private let messageTextView = UITextView()
    private let sendMessageButton = UIButton()
    
    // MARK: - Initializer
    init(viewModel: CallVanChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationBar()
        setDelegate()
        hideKeyboardWhenTappedAround()
        
        let dummy = CallVanChatDto.dummy().toDomain()
        callVanChatTableView.configure(callVanChat: dummy)
        title = dummy.roomName
    }
}

extension CallVanChatViewController: UITextViewDelegate {
    
    private func setDelegate() {
        messageTextView.delegate = self
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.appColor(.neutral500) {
            textView.text = ""
            textView.textColor = UIColor.appColor(.neutral800)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            textView.text = "메시지 보내기"
            textView.textColor = UIColor.appColor(.neutral500)
        }
    }
}

extension CallVanChatViewController {
    
    private func configureNavigationBar() {
        
        let titleLabel = UILabel().then {
            $0.text = "\(viewModel.callVanPost.title) \(viewModel.callVanPost.departureTime)"
            $0.textColor = UIColor.appColor(.neutral800)
            $0.font = UIFont.appFont(.pretendardMedium, size: 15)
        }
        let peopleImageView = UIImageView().then {
            $0.image = UIImage.appImage(asset: .callVanListPeople)?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = UIColor.appColor(.neutral600)
        }
        let paritipantsLabel = UILabel().then {
            $0.text = "\(viewModel.callVanPost.currentParticipants)/\(viewModel.callVanPost.maxParticipants)"
            $0.textColor = UIColor.appColor(.neutral600)
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
        }
        let layoutGuide = UILayoutGuide()
        let titleView = UIView()
        [titleLabel, peopleImageView, paritipantsLabel].forEach {
            titleView.addSubview($0)
        }
        [layoutGuide].forEach {
            titleView.addLayoutGuide($0)
        }
        
        layoutGuide.snp.makeConstraints {
            $0.center.equalTo(titleView)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalTo(layoutGuide)
        }
        peopleImageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
            $0.centerY.equalTo(layoutGuide)
        }
        paritipantsLabel.snp.makeConstraints {
            $0.leading.equalTo(peopleImageView.snp.trailing).offset(4)
            $0.centerY.trailing.equalTo(layoutGuide)
        }
        
        navigationItem.titleView = titleView
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.appColor(.neutral0)
        navigationItem.backButtonTitle = ""
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
}
extension CallVanChatViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral100)
        
        callVanChatTableView.do {
            $0.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            $0.backgroundColor = .white
            $0.separatorStyle = .none
            $0.showsVerticalScrollIndicator = false
        }
        wrapperView.do {
            $0.backgroundColor = UIColor.appColor(.neutral100)
        }
        sendImageButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanSendImage), for: .normal)
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
        messageTextView.do {
            $0.isScrollEnabled = false
            $0.font = UIFont.appFont(.pretendardRegular, size: 12)
            $0.backgroundColor = UIColor.appColor(.neutral0)
            $0.textContainerInset = UIEdgeInsets(top: 6.5, left: 16, bottom: 6.5, right: 16)
            $0.layer.cornerRadius = 12
            
            $0.text = "메시지 보내기"
            $0.textColor = UIColor.appColor(.neutral500)
        }
        sendMessageButton.do {
            $0.setImage(UIImage.appImage(asset: .callVanSendMessage), for: .normal)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }
    }
    
    private func setUpLayouts() {
        [sendImageButton, messageTextView, sendMessageButton].forEach {
            wrapperView.addSubview($0)
        }
        [callVanChatTableView, wrapperView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setUpConstraints() {
        callVanChatTableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(wrapperView.snp.top)
        }
        wrapperView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
        }
        sendImageButton.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.top.equalTo(wrapperView).offset(8)
            $0.leading.equalTo(wrapperView).offset(24)
        }
        sendMessageButton.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.top.equalTo(wrapperView).offset(8)
            $0.trailing.equalTo(wrapperView).offset(-24)
        }
        messageTextView.snp.makeConstraints {
            $0.top.bottom.equalTo(wrapperView).inset(8)
            $0.leading.equalTo(sendImageButton.snp.trailing).offset(8)
            $0.trailing.equalTo(sendMessageButton.snp.leading).offset(-8)
//            $0.height.greaterThanOrEqualTo(32)
        }
    }
}
