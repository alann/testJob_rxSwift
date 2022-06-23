//
//  SettingsViewController.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import UIKit
import RxCocoa
import RxSwift

class SettingsViewController: BaseViewController {
    
    private var disposeBag = DisposeBag()
        
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var birthplaceTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var organizationTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    
    @IBOutlet weak var interestTopicsTableView: UITableView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    lazy var imagePickerController = UIImagePickerController()
    
    @IBAction func changeProfileImage(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = false
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Камера", style: .default, handler: { action in
                self.imagePickerController.sourceType = .camera
                self.present(self.imagePickerController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Галерея", style: .default, handler: { action in
                self.imagePickerController.sourceType = .photoLibrary
                self.present(self.imagePickerController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.maximumDate = Date()
        
        if #available(iOS 14, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        return picker
    }()
    
    var settingsViewModel: SettingsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interestTopicsTableView.allowsSelection = true
    }
    
    override func setupViews() {
        navigationItem.title = "Профиль пользователя"
        
        dateOfBirthTextField.inputView = datePicker
    }
    
    override func setupBindings() {
        
        guard let settingsViewModel = settingsViewModel else {
            return
        }
        
        lastNameTextField.rx.text.orEmpty
            .bind(to: settingsViewModel.lastName)
            .disposed(by: disposeBag)
        
        firstNameTextField.rx.text.orEmpty
            .bind(to: settingsViewModel.firstName)
            .disposed(by: disposeBag)
        
        middleNameTextField.rx.text.orEmpty
            .bind(to: settingsViewModel.middleName)
            .disposed(by: disposeBag)
        
        birthplaceTextField.rx.text.orEmpty
            .bind(to: settingsViewModel.birthplace)
            .disposed(by: disposeBag)
        
        organizationTextField.rx.text.orEmpty
            .bind(to: settingsViewModel.organization)
            .disposed(by: disposeBag)
        
        positionTextField.rx.text.orEmpty
            .bind(to: settingsViewModel.position)
            .disposed(by: disposeBag)
        
        datePicker.rx.value
            .bind(to: settingsViewModel.dateOfBirth)
            .disposed(by: disposeBag)
        
        settingsViewModel.dateOfBirth
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { date in
                
                if let dateOfBirth = date {
                    self.datePicker.date = dateOfBirth
                    self.dateOfBirthTextField.text = dateOfBirth.getFormattedDateForUser()
                }
            })
            .disposed(by: disposeBag)

        interestTopicsTableView.rx.modelSelected(InterestTopic.self)
            .subscribe(onNext: { element in
                
                settingsViewModel.addItemsToTopics(topic: element)
            }).disposed(by: disposeBag)
        
        interestTopicsTableView.rx.modelDeselected(InterestTopic.self)
            .subscribe(onNext: { element in
                
                settingsViewModel.removeItemFromTopics(topic: element)
            }).disposed(by: disposeBag)
        
        settingsViewModel.topics
            .bind(to: interestTopicsTableView.rx.items(cellIdentifier: TopicCell.identifier, cellType: TopicCell.self)) { row, element, cell in

                cell.topicLabel.text = element.name
            }.disposed(by: disposeBag)
        
        saveButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in

                self.settingsViewModel?.updateProfile()
            }).disposed(by: disposeBag)
        
        settingsViewModel.onChangeProfileImageSuccess
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {  error in

                self.presentAlert(title: "Внимание", message: error)
            }).disposed(by: disposeBag)
        
        settingsViewModel.onChangeProfileImageFailure
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {  error in

                self.presentAlert(title: "Error", message: error)
            }).disposed(by: disposeBag)
        
        settingsViewModel.onUpdateProfileSuccess
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {  error in

                self.presentAlert(title: "Внимание", message: error)
            }).disposed(by: disposeBag)
        
        settingsViewModel.onUpdateProfileFailure
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {  error in

                self.presentAlert(title: "Error", message: error)
            }).disposed(by: disposeBag)
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[.originalImage] as? UIImage, let imageData = pickedImage.jpegData(compressionQuality: 0.5) {
            let base64String = imageData.base64EncodedString()
            settingsViewModel?.changeProfileImage(base64String: base64String, ext: ".jpeg")
        }
    }
}
