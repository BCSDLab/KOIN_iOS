//
//  CallVanListViewController.swift
//  koin
//
//  Created by 홍기정 on 3/3/26.
//

import UIKit

final class CallVanListViewController: UIViewController {
    
    // MARK: - Properties
    
    
    // MARK: - UI Components
    private let searchTextField = UITextField()
    private let searchButton = UIButton()
    private let filterButton = UIButton()
    private let callVanListCollectionView = CallVanListCollectionView()
    private let writeButton = UIButton()
    
    // MARK: - Initialzier
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureRightBarButton()
        configureNavigationBar(style: .empty)
        hideKeyboardWhenTappedAround()
        title = "콜벤팟"
        
        let postsDto = [
            CallVanListPostDto(id: 0, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               status: CallVanStateDto.closed, isJoined: false, isAuthor: false),
            CallVanListPostDto(id: 0, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               status: CallVanStateDto.closed, isJoined: true, isAuthor: false),
            CallVanListPostDto(id: 0, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               status: CallVanStateDto.closed, isJoined: false, isAuthor: true),
            CallVanListPostDto(id: 0, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               status: CallVanStateDto.completed, isJoined: false, isAuthor: false),
            CallVanListPostDto(id: 0, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               status: CallVanStateDto.completed, isJoined: true, isAuthor: false),
            CallVanListPostDto(id: 0, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               status: CallVanStateDto.completed, isJoined: false, isAuthor: true),
            CallVanListPostDto(id: 0, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               status: CallVanStateDto.recruiting, isJoined: false, isAuthor: false),
            CallVanListPostDto(id: 0, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               status: CallVanStateDto.recruiting, isJoined: true, isAuthor: false),
            CallVanListPostDto(id: 0, title: "A>B", departure: "테니스장", arrival: "시외버스터미널", departureDate: "2022-02-02", departureTime: "12:34", authorNickname: "익명", currentParticipants: 1, maxParticipants: 2,
                               status: CallVanStateDto.recruiting, isJoined: false, isAuthor: true)
        ]
        let callVanListDto = CallVanListDto(posts: postsDto, totalCount: 0, currentPage: 0, totalPage: 0)
        callVanListCollectionView.configure(posts: callVanListDto.toDomain().posts)
    }
}

extension CallVanListViewController {
    
    private func configureRightBarButton(alert: Bool = false) {
        let bellButton = UIBarButtonItem(image: UIImage.appImage(asset: .bell)?.withRenderingMode(.alwaysOriginal)
                                         , style: .plain, target: self, action: #selector(bellButtonTapped))
        navigationItem.rightBarButtonItem = bellButton
    }
    @objc private func bellButtonTapped() {}
}

extension CallVanListViewController {
    
    private func configureView() {
        setUpStyles()
        setUpLayouts()
        setUpConstraints()
    }
    
    private func setUpStyles() {
        view.backgroundColor = UIColor.appColor(.neutral0)
        
        searchTextField.do {
            $0.attributedPlaceholder = NSAttributedString(
                string: "검색어를 입력해주세요.",
                attributes: [
                    .font : UIFont.appFont(.pretendardRegular, size: 14),
                    .foregroundColor : UIColor.appColor(.neutral600)
                ])
            $0.font = UIFont.appFont(.pretendardRegular, size: 14)
            $0.textColor = UIColor.appColor(.neutral800)
            
            $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
            $0.leftViewMode = .always
            
            $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 40))
            $0.rightViewMode = .always
            
            $0.backgroundColor = UIColor.appColor(.neutral100)
            $0.layer.cornerRadius = 4
        }
        
        searchButton.do {
            $0.setImage(UIImage.appImage(asset: .search), for: .normal)
        }
        
        filterButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = AttributedString("필터", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardBold, size: 14),
                .foregroundColor : UIColor.ColorSystem.Primary.purple1300
            ]))
            configuration.image = UIImage.appImage(asset: .filter)?
                .withTintColor(
                    UIColor.ColorSystem.Primary.purple1300,
                    renderingMode: .alwaysTemplate
                )
                .resize(to: CGSize(width: 20, height: 20))
            configuration.imagePlacement = .trailing
            configuration.imagePadding = 6.5
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            $0.configuration = configuration
            
            $0.backgroundColor = UIColor.appColor(.new100)
            $0.layer.cornerRadius = 17
            $0.layer.applySketchShadow(color: .black, alpha: 0.04, x: 0, y: 2, blur: 4, spread: 0)
        }
        
        writeButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.image = UIImage.appImage(asset: .callVanCar)
            configuration.attributedTitle = AttributedString("모집하기", attributes: AttributeContainer([
                .font : UIFont.appFont(.pretendardMedium, size: 16),
                .foregroundColor : UIColor.ColorSystem.Primary.purple800
            ]))
            configuration.imagePadding = 8
            configuration.imagePlacement = .leading
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            $0.configuration = configuration
            $0.backgroundColor = UIColor.appColor(.neutral50)
            $0.layer.borderColor = UIColor.appColor(.new400).cgColor
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 21
            $0.layer.applySketchShadow(color: .black, alpha: 0.04, x: 0, y: 1, blur: 4, spread: 0)
        }
    }
    private func setUpLayouts() {
        [searchTextField, searchButton, filterButton, callVanListCollectionView, writeButton].forEach {
            view.addSubview($0)
        }
    }
    private func setUpConstraints() {
        searchTextField.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(4)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalTo(filterButton.snp.leading).offset(-12)
        }
        searchButton.snp.makeConstraints {
            $0.centerY.equalTo(searchTextField)
            $0.trailing.equalTo(searchTextField).offset(-16)
        }
        filterButton.snp.makeConstraints {
            $0.height.equalTo(34)
            $0.centerY.equalTo(searchTextField)
            $0.trailing.equalToSuperview().offset(-24)
        }
        callVanListCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        writeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-22)
        }
    }
}
