//
//  RegistrationViewModel.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import Foundation
import RxCocoa
import RxSwift

class RegistrationViewModel {
    
    private var disposeBag = DisposeBag()
    
    var lastName = BehaviorRelay<String>(value: "")
    var firstName = BehaviorRelay<String>(value: "")
    var middleName = BehaviorRelay<String>(value: "")
    var email = BehaviorRelay<String>(value: "")
    var password = BehaviorRelay<String>(value: "")
    var confirmPassword = BehaviorRelay<String>(value: "")
    
    private var isValidInputs = true
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(lastName, firstName, middleName, email, password, confirmPassword) { lName, fName, mName, email, pass, confPass in
            return lName.count > 0 && fName.count > 0 && mName.count > 0 && email.count > 0 && pass.count > 0 && confPass.count > 0
        }
    }
    
    let onShowWarningMessage = PublishSubject<String>()

    let onRegisterSuccess = PublishSubject<AuthViewModel>()
    let onRegisterFailure = PublishSubject<String>()
    
    init() {
    }

    func registerUser() {
        
        validateInputs()

        if !isValidInputs {
            return
        }
        
        guard let url = URL(string: Constants.urlStringForRegisterUser) else {
            onRegisterFailure.onNext("Невозможно создать URL")
            return
        }
        
        let input = ResisetrInput(lastName: lastName.value,
                              firstName: firstName.value,
                              middleName: middleName.value,
                              email: email.value,
                              password: password.value,
                              confirmPassword: confirmPassword.value)
        
        guard let jsonData = try? JSONEncoder().encode(input) else {
            onRegisterFailure.onNext("Невозможно преобразовать модель в данные JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.onRegisterFailure.onNext("Ошибка при вызове POST")
                return
            }
            guard let data = data else {
                self.onRegisterFailure.onNext("Не получили данные")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                self.onRegisterFailure.onNext("HTTP-запрос не выполнен")
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.onRegisterFailure.onNext("Невозможно преобразовать данные в объект JSON")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    self.onRegisterFailure.onNext("Невозможно преобразовать объект JSON в данные Pretty JSON")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    self.onRegisterFailure.onNext("Не удалось вывести JSON в String")
                    return
                }
                
                print(prettyPrintedJson)
                
                let authViewModel = AuthViewModel()
                self.onRegisterSuccess.onNext(authViewModel)
            } catch {
                self.onRegisterFailure.onNext("Невозможно преобразовать данные JSON в String")
                return
            }
        }.resume()
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func validateInputs() {
        
        isValidInputs = true
                
        var warningMessage = ""

        if !isValidEmail(email.value) {
            warningMessage.append("email введен не верно")
            warningMessage.append("\n")
            isValidInputs = false
        }
        
        if password.value != confirmPassword.value {
            warningMessage.append("введены разные пароли")
            isValidInputs = false
        }
        
        if !isValidInputs {
            onShowWarningMessage.onNext(warningMessage)
        }
        
//        можно также добавить проверку на длину полей напр.
//        if password.value.count < 5 {
//            warningMessage.append("Пароль должен быть больше 5 знаков")
//            isValidInputs = false
//        }
    }
}
