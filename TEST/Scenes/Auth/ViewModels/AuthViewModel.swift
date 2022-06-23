//
//  AuthViewModel.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import Foundation
import RxCocoa
import RxSwift

class AuthViewModel {
    
    private var disposeBag = DisposeBag()
    
    var email = BehaviorRelay<String>(value: "")
    var password = BehaviorRelay<String>(value: "")
    
    private var isValidInputs = true
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(email, password) { email, pass in
            return email.count > 0 && pass.count > 0
        }
    }
    
    let onShowWarningMessage = PublishSubject<String>()

    let onLoginSuccess = PublishSubject<SettingsViewModel>()
    let onLoginFailure = PublishSubject<String>()
    
    init() {
    }

    func checkLogin() {
        
        validateInputs()

        if !isValidInputs {
            return
        }
        
        guard let url = URL(string: Constants.urlStringForCheckLogin) else {
            onLoginFailure.onNext("Невозможно создать URL")
            return
        }
        
        let input = AuthInput(email: email.value,
                              password: password.value)
        
        guard let jsonData = try? JSONEncoder().encode(input) else {
            onLoginFailure.onNext("Невозможно преобразовать модель в данные JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.onLoginFailure.onNext("Ошибка при вызове POST")
                return
            }
            guard let data = data else {
                self.onLoginFailure.onNext("Не получили данные")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                self.onLoginFailure.onNext("HTTP-запрос не выполнен")
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.onLoginFailure.onNext("Невозможно преобразовать данные в объект JSON")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    self.onLoginFailure.onNext("Невозможно преобразовать объект JSON в данные Pretty JSON")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    self.onLoginFailure.onNext("Не удалось вывести JSON в String")
                    return
                }
                
                print(prettyPrintedJson)
                
                let settingsViewModel = SettingsViewModel()
                self.onLoginSuccess.onNext(settingsViewModel)
            } catch {
                self.onLoginFailure.onNext("Невозможно преобразовать данные JSON в String")
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
        
        if !isValidInputs {
            onShowWarningMessage.onNext(warningMessage)
        }
    }
}
