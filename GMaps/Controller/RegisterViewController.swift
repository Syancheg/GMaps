//
//  RegisterViewController.swift
//  GMaps
//
//  Created by Константин Кузнецов on 29.08.2021.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupButtons()
        setupTextFields()
    }
    
    // MARK: - Setup
    
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
