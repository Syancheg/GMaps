//
//  RegisterViewController.swift
//  GMaps
//
//  Created by Константин Кузнецов on 29.08.2021.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupButtons()
        setupTextFields()
        setupObserver()
    }
    
    // MARK: - Setup
    
    func setupObserver(){
        Observable.combineLatest(loginTextField.rx.text.asObservable().unwrap(),
                                 passwordTextField.rx.text.asObservable().unwrap())
            .map { (userName, password) in
                userName.count >= AuthConstatns.minLoginLenght && password.count >= AuthConstatns.minPasswordLength
            }
            .subscribe(onNext: { [weak self] isValid in
                self?.activeRegisterButton(isValid: isValid)
            })
            .disposed(by:disposeBag)
    }
    
    func activeRegisterButton(isValid: Bool){
        
        registerButton.isEnabled = isValid
        registerButton.backgroundColor = isValid ? UIColor.systemGreen : UIColor.systemGray
    }
    
    func setupButtons(){
        
        registerButton.layer.cornerRadius = 10
    }
    
    func setupTextFields(){
        
        loginTextField.placeholder = "Логин"
        passwordTextField.placeholder = "Пароль"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
    }
    
    // MARK: - Action
    
    @IBAction func registerButtonAction(_ sender: Any) {
        
        if let login = loginTextField.text,
           let password = passwordTextField.text,
           login != "",
           password != ""{
            let user = User()
            user.login = login
            user.password = password
            let realmService = try! RealmService()
            let userBase = realmService.register(user: user)
            alertRegister(user: userBase)
        }
    }
    
    // MARK: - Alert
    
    func alertRegister(user: User){
        
        let alertController = UIAlertController(title: "Регистрация", message: "Вы успешо зарегистрировались\nпользователь: \(user.login)", preferredStyle: .actionSheet)
        let alertActionMap = UIAlertAction(title: "Войти?", style: .default) {_ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertActionMap)
        self.present(alertController, animated: true, completion: nil)
    }

}
