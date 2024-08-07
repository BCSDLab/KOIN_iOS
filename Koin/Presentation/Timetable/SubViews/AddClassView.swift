////
////  AddClassView.swift
////  koin
////
////  Created by 김나훈 on 4/3/24.
////
//
//import Combine
//import UIKit
//
//final class AddClassView: UIView, UITextFieldDelegate {
//    
//    private var subscriptions = Set<AnyCancellable>()
//
//    var searchTextPublisher = CurrentValueSubject<String, Never>("")
//    var didTapCompleteButton = PassthroughSubject<Void, Never>()
//    
//    // MARK: - UI Components
//    
//    private let addClassLabel: UILabel = {
//       let label = UILabel()
//        label.text = "수업 추가"
//        label.font = UIFont.appFont(.pretendardMedium, size: 15)
//        label.textColor = UIColor.appColor(.bus1)
//        return label
//    }()
//    
//    private let completeButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("완료", for: .normal)
//        button.titleLabel?.font = UIFont.appFont(.pretendardRegular, size: 15)
//        button.setTitleColor(UIColor.appColor(.black), for: .normal)
//        return button
//    }()
//    
//     let searchTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "수업을 입력해주세요"
//        textField.font = UIFont.appFont(.pretendardRegular, size: 15)
//        textField.tintColor = UIColor.appColor(.gray)
//        textField.layer.borderWidth = 1.0
//        textField.layer.borderColor = UIColor.appColor(.borderGray).cgColor
//        textField.backgroundColor = UIColor.appColor(.lightGray)
//        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
//        textField.leftView = paddingView
//        textField.leftViewMode = .always
//        let imageView = UIImageView(image: UIImage.appImage(asset: .search))
//        imageView.contentMode = .scaleAspectFit
//        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 24 + 12, height: 24))
//        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
//        iconContainerView.addSubview(imageView)
//        textField.rightView = iconContainerView
//        textField.rightViewMode = .always
//        return textField
//    }()
//    
//    let addClassCollectionView: AddClassCollectionView = {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.minimumLineSpacing = 0
//        flowLayout.scrollDirection = .vertical
//        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 84)
//        let collectionView = AddClassCollectionView(frame: .zero, collectionViewLayout: flowLayout)
//        return collectionView
//    }()
//    
//    // MARK: Init
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        configureView()
//        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//}
//
//extension AddClassView {
//    @objc private func completeButtonTapped() {
//        didTapCompleteButton.send()
//    }
//    
//    @objc private func textFieldDidChange(_ textField: UITextField) {
//           searchTextPublisher.send(textField.text ?? "")
//       }
//    
//    func updateCollectionViewData(_ list: [LectureDTO]) {
//        addClassCollectionView.setLectureList(list)
//    }
//}
//// MARK: UI Settings
//
//extension AddClassView {
//    private func setUpLayOuts() {
//        [addClassLabel, completeButton, searchTextField, addClassCollectionView].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            self.addSubview($0)
//        }
//    }
//    
//    private func setUpConstraints() {
//        NSLayoutConstraint.activate([
//            
//            addClassLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
//            addClassLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
//            
//            completeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
//            completeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -22),
//            completeButton.heightAnchor.constraint(equalToConstant: 18),
//            completeButton.widthAnchor.constraint(equalToConstant: 30),
//            
//            searchTextField.topAnchor.constraint(equalTo: completeButton.bottomAnchor, constant: 15),
//            searchTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
//            searchTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
//            searchTextField.heightAnchor.constraint(equalToConstant: 36),
//            
//            addClassCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
//            addClassCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            addClassCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            addClassCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
//        ])
//    }
//    
//    private func configureView() {
//        setUpLayOuts()
//        setUpConstraints()
//        self.backgroundColor = .systemBackground  
//    }
//
//}
//
//extension AddClassView {
//    enum Metrics{
//    
//    }
//    enum Padding {
//       
//    }
//}
