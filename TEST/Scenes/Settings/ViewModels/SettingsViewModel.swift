//
//  SettingsViewModel.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import Foundation
import RxCocoa
import RxSwift

class SettingsViewModel {
    
    private var disposeBag = DisposeBag()
    
    var lastName = BehaviorRelay<String>(value: "")
    var firstName = BehaviorRelay<String>(value: "")
    var middleName = BehaviorRelay<String>(value: "")
    var birthplace = BehaviorRelay<String>(value: "")
    var dateOfBirth = BehaviorRelay<Date?>(value: nil)
    var organization = BehaviorRelay<String>(value: "")
    var position = BehaviorRelay<String>(value: "")
    var selectedTopics = BehaviorRelay<[InterestTopic]>(value: [])
    
    var selectedInterestTopics: [InterestTopic] = []
    
    let topics = BehaviorRelay<[InterestTopic]>(value: Constants.topics)
    
    let onChangeProfileImageSuccess = PublishSubject<String>()
    let onChangeProfileImageFailure = PublishSubject<String>()
    
    let onUpdateProfileSuccess = PublishSubject<String>()
    let onUpdateProfileFailure = PublishSubject<String>()
    
    private var isValidInputs = true

    var isValid: Observable<Bool> {
        return Observable.combineLatest(lastName, firstName, birthplace, selectedTopics) { lastName, firstName, birthplace, selectedTopics in
            return lastName.count > 0 && firstName.count > 0 && birthplace.count > 0 && selectedTopics.count > 0
        }
    }
    
    init() {
    }
    
    func changeProfileImage(base64String: String, ext: String) {
        
        guard let url = URL(string: Constants.urlStringForUploadAvatar) else {
            onChangeProfileImageFailure.onNext("Невозможно создать URL")
            return
        }
        
        let input = SetAvatarInput(base64: base64String, ext: ext)
        
        guard let jsonData = try? JSONEncoder().encode(input) else {
            onChangeProfileImageFailure.onNext("Невозможно преобразовать модель в данные JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.onChangeProfileImageFailure.onNext("Ошибка при вызове POST")
                return
            }
            guard let data = data else {
                self.onChangeProfileImageFailure.onNext("Не получили данные")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                self.onChangeProfileImageFailure.onNext("HTTP-запрос не выполнен")
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.onChangeProfileImageFailure.onNext("Невозможно преобразовать данные в объект JSON")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    self.onChangeProfileImageFailure.onNext("Невозможно преобразовать объект JSON в данные Pretty JSON")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    self.onChangeProfileImageFailure.onNext("Не удалось вывести JSON в String")
                    return
                }
                
                self.onChangeProfileImageSuccess.onNext("Загрузка фото профиля прошла успешно")
                print(prettyPrintedJson)

            } catch {
                self.onChangeProfileImageFailure.onNext("Невозможно преобразовать данные JSON в String")
                return
            }
        }.resume()
    }
    
    func updateProfile() {
        
        guard let url = URL(string: Constants.urlStringForUpdateProfile) else {
            onUpdateProfileFailure.onNext("Невозможно создать URL")
            return
        }
        
        guard let dateOfBirth =  dateOfBirth.value?.getFormattedDateForIInput() else {
            return
        }
        
        let input = ProfileInput(lastName: lastName.value,
                                 firstName: firstName.value,
                                 middleName: middleName.value,
                                 birthplace: birthplace.value,
                                 dateOfBirth: dateOfBirth,
                                 organization: lastName.value,
                                 position: lastName.value,
                                 topics: selectedInterestTopics)
        
        guard let jsonData = try? JSONEncoder().encode(input) else {
            onUpdateProfileFailure.onNext("Невозможно преобразовать модель в данные JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.onUpdateProfileFailure.onNext("Ошибка при вызове POST")
                return
            }
            guard let data = data else {
                self.onUpdateProfileFailure.onNext("Не получили данные")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                self.onUpdateProfileFailure.onNext("HTTP-запрос не выполнен")
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.onUpdateProfileFailure.onNext("Невозможно преобразовать данные в объект JSON")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    self.onUpdateProfileFailure.onNext("Невозможно преобразовать объект JSON в данные Pretty JSON")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    self.onUpdateProfileFailure.onNext("Не удалось вывести JSON в String")
                    return
                }
                
                print(prettyPrintedJson)
                
                self.onUpdateProfileSuccess.onNext("Профиль успешно обновлен")
            } catch {
                self.onUpdateProfileFailure.onNext("Невозможно преобразовать данные JSON в String")
                return
            }
        }.resume()
    }
    
    func addItemsToTopics(topic: InterestTopic) {
        
        self.selectedInterestTopics.append(topic)
    }
    
    func removeItemFromTopics(topic: InterestTopic) {
        
        if let index = selectedInterestTopics.firstIndex(of: topic) {
            self.selectedInterestTopics.remove(at: index)
        }
    }
}
