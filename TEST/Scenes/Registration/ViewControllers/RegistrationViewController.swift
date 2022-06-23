//
//  RegistrationViewController.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import UIKit
import RxCocoa
import RxSwift

class RegistrationViewController: BaseViewController {
    
    private var disposeBag = DisposeBag()
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var middleNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registrationButton: UIButton!
    
    private var registrationViewModel = RegistrationViewModel()
        
    @IBAction func showHidePassword(_ sender: Any) {
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func showHideConfirmPassword(_ sender: Any) {
        confirmPasswordTextField.isSecureTextEntry.toggle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func setupViews() {
        
    }
    
    override func setupBindings() {

        lastNameTextField.rx.text.orEmpty
            .bind(to: registrationViewModel.lastName)
            .disposed(by: disposeBag)
        
        firstNameTextField.rx.text.orEmpty
            .bind(to: registrationViewModel.firstName)
            .disposed(by: disposeBag)
        
        middleNameTextField.rx.text.orEmpty
            .bind(to: registrationViewModel.middleName)
            .disposed(by: disposeBag)
        
        emailTextField.rx.text.orEmpty
            .bind(to: registrationViewModel.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: registrationViewModel.password)
            .disposed(by: disposeBag)
        
        confirmPasswordTextField.rx.text.orEmpty
            .bind(to: registrationViewModel.confirmPassword)
            .disposed(by: disposeBag)
        
        registrationButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in

                self.registrationViewModel.registerUser()
            }).disposed(by: disposeBag)

        //валидацию решил сделать не по сценарию. Изначально ограничил возможность нажатия пользователем кнопки регистрации при незаполненных полях
        registrationViewModel.isValid
            .subscribe(onNext: { isValid in
                
                self.registrationButton.isEnabled = isValid
                self.registrationButton.backgroundColor = isValid ? Constants.Colors.mainBlue : Constants.Colors.mainBlueWithOpacity
            }).disposed(by: disposeBag)
        
        registrationViewModel.onShowWarningMessage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { message in
                
                self.presentAlert(title: "Проверьте правильность ввода", message: message)
            })
            .disposed(by: disposeBag)

        registrationViewModel.onRegisterSuccess
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { authViewModel in

                let authViewController = AuthViewController.instantiate(fromAppStoryboard: .Auth)
                authViewController.authViewModel = authViewModel
                self.navigationController?.pushViewController(authViewController, animated: true)
            }).disposed(by: disposeBag)

        registrationViewModel.onRegisterFailure
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {  error in

                self.presentAlert(title: "Error", message: error)
            }).disposed(by: disposeBag)
    }
    
    @objc func touch() {
        self.view.endEditing(true)
    }
}
