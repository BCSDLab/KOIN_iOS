//
//  EditorViewController.swift
//  dev_koin
//
//  Created by 정태훈 on 2020/02/02.
//  Copyright © 2020 정태훈. All rights reserved.
//

import UIKit
import SwiftUI
import RichEditorView
import Alamofire
import CryptoKit
import CryptoTokenKit
import IGColorPicker


struct TempRichEditor: UIViewControllerRepresentable {
    var controller: TempViewController = UIStoryboard(name: "Editor", bundle: nil).instantiateViewController(identifier: "TempViewController") as! TempViewController
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var parentViewModel: CommunityViewModel<TempArticle>
    var is_edit: Bool = false
    var title: String = ""
    var content: String = ""
    var nickname: String = ""
    var article_id: Int = -1
    
    func makeUIViewController(context: Context) -> TempViewController {
        controller.is_edit = is_edit
        controller.presentationMode = presentationMode
        if is_edit {
            controller.article_title = title
            controller.content = content
            controller.nickname = nickname
            controller.article_id = article_id
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: TempViewController, context: Context) {
        
    }
    
    
    typealias UIViewControllerType = TempViewController
    
}

struct RichEditor: UIViewControllerRepresentable {
    var controller: ViewController = UIStoryboard(name: "Editor", bundle: nil).instantiateViewController(identifier: "ViewController") as! ViewController
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var parentViewModel: CommunityViewModel<Article>
    var is_edit: Bool = false
    var board_id: Int = -1
    var title: String = ""
    var content: String = ""
    var article_id: Int = -1
    var token: String = ""
    
    func makeUIViewController(context: Context) -> ViewController {
        controller.is_edit = is_edit
        controller.board_id = board_id
        controller.token = token
        controller.presentationMode = presentationMode
        if is_edit {
            controller.title = title
            controller.article_title = title
            controller.content = content
            controller.article_id = article_id
        }
        return controller

    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {

    }
    
    func onDisappear(perform action: (() -> Void)? = nil) {
        self.parentViewModel.fetchCommunity()
    }
    
    
    typealias UIViewControllerType = ViewController
    
}

//375, 640
class ViewController: UIViewController {
    var communityData: CommunityController = CommunityController(board_id: -1)
    
    @IBOutlet var editorView: RichEditorView!
    @IBOutlet var titleField: UITextField!
    var colorPickerView: ColorPickerView!
    var presentationMode: Binding<PresentationMode>? = nil
    let picker = UIImagePickerController()
    var is_edit: Bool = false
    var board_id: Int = -1
    var article_id: Int = -1
    var content:String = ""
    var article_title:String = ""
    var token: String = ""
    
    var showError: Bool = false
    var errorText: String = ""
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()
    
    //var errorAlert = UIAlertController(title: "에러", message: "", preferredStyle: .actionSheet)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        communityData = CommunityController(board_id: self.board_id)
        titleField.delegate = self
        titleField.text?.append(article_title)
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.placeholder = "내용을 입력해주세요."
        editorView.html = content
        editorView.setEditorFontColor(UIColor(named: "black")!)

        toolbar.delegate = self
        toolbar.editor = editorView
        
        colorPickerView = ColorPickerView()
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.colors = [UIColor.black, UIColor.white, UIColor(red: 1, green: 0.24, blue: 0, alpha: 1), UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), UIColor(red: 1, green: 0.77, blue: 0, alpha: 1), UIColor(red: 0.75, green: 0, blue: 1, alpha: 1), UIColor(red: 0, green: 0.82, blue: 0.18, alpha: 1)]
        

        
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }
        
        var options = toolbar.options
        
        
        let image = RichEditorOptionItem(image: UIImage(named: "insert_image"), title: "image") { toolbar in
            
            let alert =  UIAlertController(title: "", message: "", preferredStyle: .actionSheet)

            let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in
                self.picker.sourceType = .photoLibrary
                self.present(self.picker, animated: false, completion: nil)
            }

            let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in
                self.picker.sourceType = .camera
                self.present(self.picker, animated: false, completion: nil)
            }

            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

            alert.addAction(library)
            alert.addAction(camera)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let link_action = RichEditorOptionItem(image: UIImage(named: "insert_link"), title: "link") { toolbar in
            
            let alert =  UIAlertController(title: "링크 추가", message: "", preferredStyle: .alert)
            
            alert.addTextField() {
                $0.placeholder = "주소를 입력하세요."
            }


            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "입력", style: .default) { (action) in
                if toolbar.editor?.hasRangeSelection == true {
                toolbar.editor?.insertLink((alert.textFields?[0].text)!, title: "ios link")
                }
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let text_color_action = RichEditorOptionItem(image: UIImage(named: "text_color"), title: "textColor") { toolbar in
            
            let alert =  UIAlertController(title: "색을 선택해주세요", message: "\n\n\n\n", preferredStyle: .actionSheet)
            alert.view.addSubview(self.colorPickerView)
            self.colorPickerView.translatesAutoresizingMaskIntoConstraints = false
            
            self.colorPickerView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor)
                .isActive = true
            self.colorPickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 60)
                .isActive = true
            self.colorPickerView.widthAnchor.constraint(equalToConstant: alert.view.frame.width - 40)
                .isActive = true
            self.colorPickerView.heightAnchor.constraint(equalToConstant: alert.view.frame.height / 16)
            .isActive = true

            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "추가", style: .default) { (action) in
                
                let color = self.colorPickerView.colors[self.colorPickerView.indexOfSelectedColor!]
                toolbar.editor?.setTextColor(color)
            }
            
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let back_color_action = RichEditorOptionItem(image: UIImage(named: "bg_color"), title: "backColor") { toolbar in
            
            let alert =  UIAlertController(title: "색을 선택해주세요", message: "\n\n\n\n", preferredStyle: .actionSheet)
            
            alert.view.addSubview(self.colorPickerView)
            self.colorPickerView.translatesAutoresizingMaskIntoConstraints = false
            
            self.colorPickerView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor)
                .isActive = true
            self.colorPickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 60)
                .isActive = true
            self.colorPickerView.widthAnchor.constraint(equalToConstant: alert.view.frame.width - 40)
                .isActive = true
            self.colorPickerView.heightAnchor.constraint(equalToConstant: alert.view.frame.height / 16)
            .isActive = true

            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "추가", style: .default) { (action) in
                
                let color = self.colorPickerView.colors[self.colorPickerView.indexOfSelectedColor!]
                toolbar.editor?.setTextBackgroundColor(color)
            }
            
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        options[options.count-2] = image
        options[options.count-1] = link_action
        options[9] = text_color_action
        options[10] = back_color_action
        toolbar.options = options
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let send = UIBarButtonItem(title: "제출", style: .plain, target: self, action: #selector(sendAction))
        
        if is_edit {
            self.parent?.navigationItem.title = "수정"
        } else {
            self.parent?.navigationItem.title = "작성"
        }
        self.parent?.navigationItem.rightBarButtonItem = send
    }
    
    @objc func sendAction() {
        if self.is_edit {
            let alert =  UIAlertController(title: "수정하기", message: "수정하시겠습니까?", preferredStyle: .actionSheet)

            let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "수정", style: .default) { (action) in
                self.communityData.update_article(token: self.token, article_id: self.article_id, board_id: self.board_id, title: self.titleField.text!, content: self.editorView.html.replacingOccurrences(of: "div", with: "p")) { (result, error) in
                    if result {
                        self.errorText = ""
                        self.showError = false
                        self.presentationMode?.wrappedValue.dismiss()
                    } else {
                        self.errorText = (error?.localizedDescription)!
                        self.showError = true
                        let errorAlert = UIAlertController(title: "에러", message: self.errorText, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                        errorAlert.addAction(cancel)
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                    
                }
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert =  UIAlertController(title: "제출하기", message: "제출하시겠습니까?", preferredStyle: .actionSheet)

            let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "제출", style: .default) { (action) in
                self.communityData.put_article(token: self.token, board_id: self.board_id, title: self.titleField.text!, content: self.editorView.contentHTML.replacingOccurrences(of: "div", with: "p")) { (result, error) in
                    if result {
                        self.errorText = ""
                        self.showError = false
                        self.parent?.navigationController?.popViewController(animated: true)
                    } else {
                        self.errorText = (error?.localizedDescription)!
                        self.showError = true
                        let errorAlert = UIAlertController(title: "에러", message: self.errorText, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                        errorAlert.addAction(cancel)
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    @objc func checkAction() {
        if is_edit {
            self.communityData.update_article(token: self.token, article_id: self.article_id, board_id: self.board_id, title: self.titleField.text!, content: self.editorView.html.replacingOccurrences(of: "div", with: "p")) { (result, error) in
                if result {
                    self.errorText = ""
                    self.showError = false
                    self.presentationMode?.wrappedValue.dismiss()
                } else {
                    self.errorText = (error?.localizedDescription)!
                    self.showError = true
                    let errorAlert = UIAlertController(title: "에러", message: self.errorText, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                    errorAlert.addAction(cancel)
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
            }
        } else {
            self.communityData.put_article(token: self.token, board_id: self.board_id, title: self.titleField.text!, content: self.editorView.contentHTML.replacingOccurrences(of: "div", with: "p")) { (result, error) in
                if result {
                    self.errorText = ""
                    self.showError = false
                    self.parent?.navigationController?.popViewController(animated: true)
                } else {
                    self.errorText = (error?.localizedDescription)!
                    self.showError = true
                    let errorAlert = UIAlertController(title: "에러", message: self.errorText, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                    errorAlert.addAction(cancel)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func checkErrorAlert() {
        
    }
    
    
    
    
}

extension ViewController: ColorPickerViewDelegate {

  func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
    // A color has been selected
  }

  // This is an optional method
  func colorPickerView(_ colorPickerView: ColorPickerView, didDeselectItemAt indexPath: IndexPath) {
    // A color has been deselected
  }

}

extension ViewController: ColorPickerViewDelegateFlowLayout {

  // ------------------------------------------------------------------
  // All these methods are optionals, your are not to implement them 🖖🏻
  // ------------------------------------------------------------------

  func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // The size for each cell
    // 👉🏻 WIDTH AND HEIGHT MUST BE EQUALS!
    return CGSize(width: 48, height: 48)
  }

  func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    // Space between cells
    return 22
  }

  func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    // Space between rows
    return 0
  }

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                    let imageData = image.jpegData(compressionQuality: 0.50)
            let url = CommonVariables.isStage ? "http://stage.api.koreatech.in/upload/image" : "https://api.koreatech.in/upload/image"
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer " + token
            ]

            AF.upload(multipartFormData: { multiPart in
                multiPart.append( imageData! , withName: "image", fileName: "uploaded_ios.png", mimeType: "image/png")
            }, to: url, headers: headers)
                .uploadProgress(queue: .main, closure: { progress in
                    //Current upload progress of file
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                .responseString { response in
                    if let image_url = response.value {
                        self.toolbar.editor?.insertImage("https://\(image_url)", alt: "koin")
                    }
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: RichEditorDelegate {

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        //self.editorView = editor
    }
    
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //self.titleField = textField
    }
    
}

extension ViewController: RichEditorToolbarDelegate {

    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://stage-static.koreatech.in/upload/2020/02/20/a929792f-5fbd-4195-bd09-cbdd649dd221-1582206890825.jpg", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            toolbar.editor?.insertLink("http://naver.com",title: "aaaa")
        }
    }
}


class TempViewController: UIViewController {
    var communityData: CommunityController = CommunityController(board_id: -2)
    @EnvironmentObject var parentViewModel: CommunityViewModel<TempArticle>
    var colorPickerView: ColorPickerView!
    var presentationMode: Binding<PresentationMode>? = nil
    @IBOutlet var tempEditorView: RichEditorView!
    @IBOutlet var tempTitleField: UITextField!
    @IBOutlet var tempNicknameField: UITextField!
    @IBOutlet var tempPasswordField: UITextField!
    
    let picker = UIImagePickerController()
    var is_edit: Bool = false
    var article_title: String = ""
    var content: String = ""
    var article_id: Int = -1
    var nickname: String = ""
    
    var showError: Bool = false
    var errorText: String = ""
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        toolbar.options = RichEditorDefaultOption.all
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempTitleField.text = article_title
        
        picker.delegate = self
        tempEditorView.delegate = self
        tempEditorView.inputAccessoryView = toolbar
        tempEditorView.placeholder = "내용을 입력해주세요."

        toolbar.delegate = self
        toolbar.editor = tempEditorView
        
        
        colorPickerView = ColorPickerView()
        colorPickerView.delegate = self
        colorPickerView.layoutDelegate = self
        colorPickerView.colors = [UIColor.black, UIColor.white, UIColor(red: 1, green: 0.24, blue: 0, alpha: 1), UIColor(red: 0, green: 0.5, blue: 1, alpha: 1), UIColor(red: 1, green: 0.77, blue: 0, alpha: 1), UIColor(red: 0.75, green: 0, blue: 1, alpha: 1), UIColor(red: 0, green: 0.82, blue: 0.18, alpha: 1)]

        // We will create a custom action that clears all the input text when it is pressed
        let item = RichEditorOptionItem(image: nil, title: "Clear") { toolbar in
            toolbar.editor?.html = ""
        }
        tempEditorView.html = content
        tempNicknameField.text = nickname

        var options = toolbar.options
        
        let image = RichEditorOptionItem(image: UIImage(named: "insert_image"), title: "image") { toolbar in
            
            let alert =  UIAlertController(title: "", message: "", preferredStyle: .actionSheet)

            let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in
                self.picker.sourceType = .photoLibrary
                self.present(self.picker, animated: false, completion: nil)
            }

            let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in
                self.picker.sourceType = .camera
                self.present(self.picker, animated: false, completion: nil)
            }

            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)

            alert.addAction(library)
            alert.addAction(camera)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let link_action = RichEditorOptionItem(image: UIImage(named: "insert_link"), title: "link") { toolbar in
            
            let alert =  UIAlertController(title: "링크 추가", message: "", preferredStyle: .alert)
            
            alert.addTextField() {
                $0.placeholder = "주소를 입력하세요."
            }


            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "입력", style: .default) { (action) in
                if toolbar.editor?.hasRangeSelection == true {
                toolbar.editor?.insertLink((alert.textFields?[0].text)!, title: "ios link")
                }
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let text_color_action = RichEditorOptionItem(image: UIImage(named: "text_color"), title: "textColor") { toolbar in
            
            let alert =  UIAlertController(title: "색을 선택해주세요", message: "\n\n\n\n", preferredStyle: .actionSheet)
            alert.view.addSubview(self.colorPickerView)
            self.colorPickerView.translatesAutoresizingMaskIntoConstraints = false
            
            self.colorPickerView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor)
                .isActive = true
            self.colorPickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 60)
                .isActive = true
            self.colorPickerView.widthAnchor.constraint(equalToConstant: alert.view.frame.width - 40)
                .isActive = true
            self.colorPickerView.heightAnchor.constraint(equalToConstant: alert.view.frame.height / 16)
            .isActive = true

            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "추가", style: .default) { (action) in
                
                let color = self.colorPickerView.colors[self.colorPickerView.indexOfSelectedColor!]
                toolbar.editor?.setTextColor(color)
            }
            
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let back_color_action = RichEditorOptionItem(image: UIImage(named: "bg_color"), title: "backColor") { toolbar in
            
            let alert =  UIAlertController(title: "색을 선택해주세요", message: "\n\n\n\n", preferredStyle: .actionSheet)
            alert.view.addSubview(self.colorPickerView)
            self.colorPickerView.translatesAutoresizingMaskIntoConstraints = false
            
            self.colorPickerView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor)
                .isActive = true
            self.colorPickerView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 60)
                .isActive = true
            self.colorPickerView.widthAnchor.constraint(equalToConstant: alert.view.frame.width - 40)
                .isActive = true
            self.colorPickerView.heightAnchor.constraint(equalToConstant: alert.view.frame.height / 16)
            .isActive = true

            let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "추가", style: .default) { (action) in
                
                let color = self.colorPickerView.colors[self.colorPickerView.indexOfSelectedColor!]
                toolbar.editor?.setTextBackgroundColor(color)
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        options[options.count-2] = image
        options[options.count-1] = link_action
        options[9] = text_color_action
        options[10] = back_color_action
        toolbar.options = options
         
        
    }
    
    func hashed(pw: String) -> String{
        // 비밀번호를 먼전 Data로 변환하여
        let inputData = Data(pw.utf8)
        // SHA256을 이용해 해시 처리한 다음
        let hashed = SHA256.hash(data: inputData)
        // 해시 당 16진수 2자리로 설정하여 합친다.
        let hashPassword = hashed.compactMap {String(format: "%02x", $0)}.joined().trimmingCharacters(in: CharacterSet.newlines)
        return hashPassword
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let send = UIBarButtonItem(title: "제출", style: .plain, target: self, action: #selector(sendAction))
        
        if is_edit {
            self.parent?.navigationItem.title = "수정"
        } else {
            self.parent?.navigationItem.title = "작성"
        }
        self.parent?.navigationItem.rightBarButtonItem = send
    }
    /*
    override func viewWillDisappear(_ animated: Bool) {
        let alert =  UIAlertController(title: "뒤로 가기", message: "작성을 취소하시겠습니까?", preferredStyle: .actionSheet)

        let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "취소", style: .default) { (action) in
            self.presentationMode?.wrappedValue.dismiss()
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        let alert =  UIAlertController(title: "뒤로 가기", message: "작성을 취소하시겠습니까?", preferredStyle: .actionSheet)

        let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "취소", style: .default) { (action) in
            self.presentationMode?.wrappedValue.dismiss()
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    */
    @objc func sendAction() {
        if self.is_edit {
            let alert =  UIAlertController(title: "수정하기", message: "수정하시겠습니까?", preferredStyle: .actionSheet)

            let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "수정", style: .default) { (action) in
                self.communityData.update_temp_article(password: self.hashed(pw: self.tempPasswordField.text!), article_id: self.article_id, title: self.tempTitleField.text!, nickname: self.tempNicknameField.text!, content: self.tempEditorView.html.replacingOccurrences(of: "div", with: "p")) { (result, error) in
                    if result {
                        self.errorText = ""
                        self.showError = false
                        self.presentationMode?.wrappedValue.dismiss()
                    } else {
                        self.errorText = (error?.localizedDescription)!
                        self.showError = true
                        let errorAlert = UIAlertController(title: "에러", message: self.errorText, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                        errorAlert.addAction(cancel)
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                    
                }
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert =  UIAlertController(title: "제출하기", message: "제출하시겠습니까?", preferredStyle: .actionSheet)

            let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "제출", style: .default) { (action) in
                self.communityData.put_temp_article(password: self.hashed(pw: self.tempPasswordField.text!), title: self.tempTitleField.text!, nickname: self.tempNicknameField.text!, content: self.tempEditorView.html.replacingOccurrences(of: "div", with: "p")) { (result, error) in
                    if result {
                        self.errorText = ""
                        self.showError = false
                        self.parent?.navigationController?.popViewController(animated: true)
                    } else {
                        self.errorText = (error?.localizedDescription)!
                        self.showError = true
                        let errorAlert = UIAlertController(title: "에러", message: self.errorText, preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                        errorAlert.addAction(cancel)
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    @objc func checkAction() {
        if self.is_edit {
            communityData.update_temp_article(password: hashed(pw: self.tempPasswordField.text!), article_id: self.article_id, title: self.tempTitleField.text!, nickname: self.tempNicknameField.text!, content: self.tempEditorView.html.replacingOccurrences(of: "div", with: "p")) { (result, error) in
                if result {
                    self.errorText = ""
                    self.showError = false
                    self.presentationMode?.wrappedValue.dismiss()
                } else {
                    self.errorText = (error?.localizedDescription)!
                    self.showError = true
                    let errorAlert = UIAlertController(title: "에러", message: self.errorText, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                    errorAlert.addAction(cancel)
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
            }
        } else {
            communityData.put_temp_article(password: hashed(pw: self.tempPasswordField.text!), title: self.tempTitleField.text!, nickname: self.tempNicknameField.text!, content: self.tempEditorView.html.replacingOccurrences(of: "div", with: "p")) { (result, error) in
                if result {
                    self.errorText = ""
                    self.showError = false
                    self.parent?.navigationController?.popViewController(animated: true)
                } else {
                    self.errorText = (error?.localizedDescription)!
                    self.showError = true
                    let errorAlert = UIAlertController(title: "에러", message: self.errorText, preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "닫기", style: .cancel, handler: nil)
                    errorAlert.addAction(cancel)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
}

extension TempViewController: RichEditorDelegate {

    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        
    }
    
}

extension TempViewController: RichEditorToolbarDelegate {

    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }

    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }

    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }

    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        toolbar.editor?.insertImage("https://stage-static.koreatech.in/upload/2020/02/20/a929792f-5fbd-4195-bd09-cbdd649dd221-1582206890825.jpg", alt: "Gravatar")
    }

    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if toolbar.editor?.hasRangeSelection == true {
            toolbar.editor?.insertLink("http://naver.com",title: "aaaa")
        }
    }
}
    
    extension TempViewController: ColorPickerViewDelegate {

      func colorPickerView(_ colorPickerView: ColorPickerView, didSelectItemAt indexPath: IndexPath) {
        // A color has been selected
      }

      // This is an optional method
      func colorPickerView(_ colorPickerView: ColorPickerView, didDeselectItemAt indexPath: IndexPath) {
        // A color has been deselected
      }

    }

extension TempViewController: ColorPickerViewDelegateFlowLayout {

  // ------------------------------------------------------------------
  // All these methods are optionals, your are not to implement them 🖖🏻
  // ------------------------------------------------------------------

  func colorPickerView(_ colorPickerView: ColorPickerView, sizeForItemAt indexPath: IndexPath) -> CGSize {
    // The size for each cell
    // 👉🏻 WIDTH AND HEIGHT MUST BE EQUALS!
    return CGSize(width: 48, height: 48)
  }

  func colorPickerView(_ colorPickerView: ColorPickerView, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    // Space between cells
    return 22
  }

  func colorPickerView(_ colorPickerView: ColorPickerView, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    // Space between rows
    return 0
  }

}

extension TempViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                    let imageData = image.jpegData(compressionQuality: 0.50)
            let url = CommonVariables.isStage ? "http://stage.api.koreatech.in/temp/items/image/thumbnail/upload" : "https://api.koreatech.in/temp/items/image/thumbnail/upload"

            AF.upload(multipartFormData: { multiPart in
                multiPart.append( imageData! , withName: "image", fileName: "uploaded_ios.png", mimeType: "image/png")
            }, to: url)
                .uploadProgress(queue: .main, closure: { progress in
                    //Current upload progress of file
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                .responseJSON { response in
                    switch response.result {
                    case .success(let value as [String: Any]):
                        let image_url = value["url"]
                        self.toolbar.editor?.insertImage(image_url as! String, alt: "koin")
                    case .failure(let error):
                        print(error)
                    default:
                        fatalError("received non-dictionary JSON response")
                    }
            }
            
        }
        dismiss(animated: true, completion: nil)
    }
    
}


