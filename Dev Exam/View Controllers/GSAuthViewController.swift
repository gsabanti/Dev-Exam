//
//  GSAuthViewController.swift
//  Dev Exam
//
//  Created by George Sabanov on 31.07.2018.
//  Copyright © 2018 George Sabanov. All rights reserved.
//

import UIKit
import InputMask

class GSAuthViewController: UIViewController, MaskedTextFieldDelegateListener {
    var listener: MaskedTextFieldDelegate?
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollview: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         Не описана обработка момента, когда пользовательские данные, сохраненные в Keychain, отличаются по маске от той, что передается с сервера.
         Например, сохранено 7 900 000 00 00
         Маска с сервера 44 900 000....
         Что делать в таком случае?
         Сейчас я просто не запрашиваю маску.
        */
        if(AuthManager.authorised)
        {
            self.phoneTextField.text = AuthManager.userPhone
            self.passwordTextField.text = AuthManager.userPassword
        }
        else
        {
            AuthManager.phoneMask(success: { [weak self] (mask) in
                DispatchQueue.main.async {
                    self?.listener = MaskedTextFieldDelegate(format: mask.formatPhoneString())
                    self?.listener?.delegate = self
                    self?.phoneTextField.delegate = self?.listener
                    self?.phoneTextField.isEnabled = true
                    self?.phoneTextField.placeholder = mask
                }
            }) { (failureString) in
                self.showFailureAlert(message: failureString)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(GSAuthViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GSAuthViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)    

    }

    func textField(_ textField: UITextField, didFillMandatoryCharacters complete: Bool, didExtractValue value: String) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func auth(sender: UIButton?)
    {
        guard !self.phoneTextField.text!.isEmpty && !self.passwordTextField.text!.isEmpty else { self.showFailureAlert(message: NSLocalizedString("MISSING_FIELDS", comment: "")); return }
        AuthManager.authorize(phone: self.phoneTextField.text ?? "", password: self.passwordTextField.text ?? "", success: { 
            DispatchQueue.main.async {
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "feed") as! GSFeedTableViewController
                let navVC = UINavigationController(rootViewController: vc)
                self.present(navVC, animated: true, completion: nil)
            }
        }) { (failureString) in
            DispatchQueue.main.async {
                self.showFailureAlert(message: failureString)
            }
        }
    }
}

//Открытие/Закрытие клавиатуры
extension GSAuthViewController
{
    @objc func keyboardWillShow(notification: NSNotification) {        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomConstraint.constant = keyboardSize.height
        }        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.bottomConstraint.constant = 0
    }
}
