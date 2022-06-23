//
//  AuthViewController.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import UIKit
import RxCocoa
import RxSwift

class AuthViewController: BaseViewController {
    
    private var disposeBag = DisposeBag()

    @IBOutlet weak var scrollView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var authViewModel: AuthViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.touch))
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(recognizer)
    }
    
    override func setupViews() {
        navigationItem.title = "Экран авторизации"
    }
    
    override func setupBindings() {
        
        guard let authViewModel = authViewModel else {
            return
        }

        emailTextField.rx.text.orEmpty
            .bind(to: authViewModel.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: authViewModel.password)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in

                self.authViewModel?.checkLogin()
            }).disposed(by: disposeBag)
        
        authViewModel.isValid
            .subscribe(onNext: { isValid in
                
                self.loginButton.isEnabled = isValid
                self.loginButton.backgroundColor = isValid ? Constants.Colors.mainBlue : Constants.Colors.mainBlueWithOpacity
            }).disposed(by: disposeBag)
        
        authViewModel.onShowWarningMessage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { message in
                
                self.presentAlert(title: "Проверьте правильность ввода", message: message)
            })
            .disposed(by: disposeBag)

        authViewModel.onLoginSuccess
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { settingsViewModel in

                let settingsViewController = SettingsViewController.instantiate(fromAppStoryboard: .Settings)
                settingsViewController.settingsViewModel = settingsViewModel
                self.navigationController?.pushViewController(settingsViewController, animated: true)
            }).disposed(by: disposeBag)

        authViewModel.onLoginFailure
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {  error in

                self.presentAlert(title: "Error", message: error)
            }).disposed(by: disposeBag)
    }
    
    @objc func touch() {
        self.view.endEditing(true)
    }
}
