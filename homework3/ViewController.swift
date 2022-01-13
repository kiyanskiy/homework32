//
//  ViewController.swift
//  homework3
//
//  Created by Oleksandr Kiianskyi on 08.12.2021.
//

import UIKit
import RxSwift
import RxCocoa

enum Buttons{
    case firstButton, secondButton
}
class ViewController: UIViewController {
    let loginViewModel = LoginViewModel()
    let bag = DisposeBag()
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var searchLabel: UITextField!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var rocketLabel: UILabel!
    var counter = BehaviorRelay<Int>(value: 0)
    var pressedButtons = BehaviorRelay<[Buttons]>(value: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        enterButton.isEnabled = false
        loginTextField.becomeFirstResponder()
        loginTextField.rx.text.map{$0 ?? ""}.bind(to: loginViewModel.loginTextPublishSubject).disposed(by: bag)
        passwordTextField.rx.text.map{$0 ?? ""}.bind(to: loginViewModel.passwordTextPublishSubject).disposed(by: bag)
        loginViewModel.isValid().map{$0 == "" ? true : false}.bind(to: enterButton.rx.isEnabled).disposed(by: bag)
        loginViewModel.isValid().map{$0 == "1" ? "" : $0}.bind(to: errorLabel.rx.text).disposed(by: bag)
        searchLabel.rx.text.debounce(.milliseconds(500), scheduler: MainScheduler.instance).map{ "Отправка запроса для \($0 == nil ? "" : $0!)"}.asObservable().subscribe(onNext: {text in print(text)}).disposed(by: bag)
        counter.subscribe(onNext: {self.counterLabel.text = String($0) }).disposed(by: bag)
        pressedButtons.map{$0.count == 2 ? "Ракета запущена" : ""}.bind(to: rocketLabel.rx.text).disposed(by: bag)
    }

    @IBAction func increaseCounter(_ sender: Any) {
        var currentCounter = counter.value
        currentCounter = currentCounter + 1
        self.counter.accept(currentCounter)

    }
    @IBAction func enter(_ sender: Any) {
    }
    @IBAction func firstButtonTap(_ sender: Any) {
        var currentButtons = pressedButtons.value
        currentButtons.append(.firstButton)
        
        self.pressedButtons.accept(Array(Set(currentButtons)))
    }
    
    @IBAction func secondButtonTap(_ sender: Any) {
        var currentButtons = pressedButtons.value
        currentButtons.append(.secondButton)
        
        self.pressedButtons.accept(Array(Set(currentButtons)))
    }
}
class LoginViewModel{
    let loginTextPublishSubject = PublishSubject<String>()
    let passwordTextPublishSubject = PublishSubject<String>()
    
    func isValid()->Observable<String>{

        return Observable.combineLatest(loginTextPublishSubject.asObservable(), passwordTextPublishSubject.asObservable()).map{ login, password in
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            let correctEmail = emailTest.evaluate(with: login)
            if !correctEmail{
                return "Некоректная почта"
            }else if password.count < 6{
                return "Слишком короткий пароль"
            }else{
                return ""
            }
        }
    }
}


