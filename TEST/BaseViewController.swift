//
//  BaseViewController.swift
//  TEST
//
//  Created by Ulan Nurmatov on 30.10.2021.
//

import UIKit

class BaseViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupViews()
        setupBindings()
    }
    
    deinit {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        closeKeyboard()
    }
    
    func setupViews() {
    }
    
    func setupBindings() {
    }
    
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
