//
//  AuthViewController.swift
//  GMaps
//
//  Created by Константин Кузнецов on 29.08.2021.
//

import UIKit

class AuthViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet var router: AuthRouter!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupButton()
        setupTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupButton(){
        
        loginButton.layer.cornerRadius = 10
        registerButton.layer.cornerRadius = 10
    }
    
    func setupTextFields(){
        
        loginTextField.placeholder = "Логин"
        passwordTextField.placeholder = "Пароль"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocorrectionType = .no
    }
    
    
    
    @IBAction func loginButtonAction(_ sender: Any) {
        
        if let login = loginTextField.text,
           let password = passwordTextField.text {
            let user = User()
            user.login = login
            user.password = password
            let realmService = try! RealmService()
            if realmService.login(user: user){
                router.showMaps()
            } else {
                alertAuth()
            }
        }
    }
    
    func alertAuth () {
        
        let alertController = UIAlertController(title: "Ошибка входа", message: "Не верный логин или пароль!", preferredStyle: .actionSheet)
        let alertAction = UIAlertAction(title: "Попробовать снова", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        
        router.showRegister()
    }

}

final class AuthRouter: BaseRouter {
    
    func showRegister(){
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(RegisterViewController.self)
        show(controller, style: .modal(animated: true))
    }
    
    func showMaps(){
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(MainViewController.self)
        show(controller, style: .push(animated: true))
    }
    
}
