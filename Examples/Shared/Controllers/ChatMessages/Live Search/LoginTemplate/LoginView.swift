//
//  LoginView.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 30/10/20.
//  Copyright © 2020 Kore. All rights reserved.
//

import UIKit
protocol LoginViewDelegate {
    func LoginViewSucess()
}

class LoginView: UIView {
    
    public var delegate: LoginViewDelegate?
    var titleLbl: UILabel!
    var userIdLabel: UILabel!
    var userIdTextField: UITextField!
    var passwordLabel: UILabel!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var newUserLabel: UILabel!
    var registerButton: UIButton!
    var forgotPasswordButton: UIButton!
    var errorLabel: UILabel!
    
    convenience init() {
           self.init(frame: CGRect.zero)
       }
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           self.setupViews()
       }
       
       required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           self.setupViews()
       }
       
       fileprivate func setupViews() {
        if #available(iOS 11.0, *) {
               self.roundCorners([ .layerMinXMinYCorner, .layerMaxXMinYCorner,], radius: 20.0, borderColor: UIColor.lightGray, borderWidth: 0)
           } else {
               // Fallback on earlier versions
           }
           self.backgroundColor = UIColor.init(red: 240/255, green: 242/255, blue: 244/255, alpha: 1.0)
        
        titleLbl = UILabel(frame: CGRect.zero)
        titleLbl.textColor = .black
        titleLbl.text = "Please login to continue"
        titleLbl.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        titleLbl.numberOfLines = 0
        titleLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        titleLbl.isUserInteractionEnabled = true
        titleLbl.contentMode = UIView.ContentMode.topLeft
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.titleLbl)
        titleLbl.adjustsFontSizeToFitWidth = true
        titleLbl.backgroundColor = .clear
        titleLbl.layer.cornerRadius = 6.0
        titleLbl.clipsToBounds = true
        titleLbl.sizeToFit()
        
        userIdLabel = UILabel(frame: CGRect.zero)
        userIdLabel.textColor = .black
        userIdLabel.text = "User ID"
        userIdLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        userIdLabel.numberOfLines = 0
        userIdLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        userIdLabel.isUserInteractionEnabled = true
        userIdLabel.contentMode = UIView.ContentMode.topLeft
        userIdLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.userIdLabel)
        userIdLabel.adjustsFontSizeToFitWidth = true
        userIdLabel.backgroundColor = .clear
        userIdLabel.layer.cornerRadius = 6.0
        userIdLabel.clipsToBounds = true
        userIdLabel.sizeToFit()
        
        userIdTextField = UITextField(frame: CGRect.zero)
        userIdTextField.borderStyle = .none
        userIdTextField.isSecureTextEntry = false
        userIdTextField.delegate = self
        userIdTextField.text = ""
        userIdTextField.borderStyle = UITextField.BorderStyle.none
        userIdTextField.layer.borderWidth = 1
        userIdTextField.layer.cornerRadius = 3
        userIdTextField.layer.borderColor = UIColor.lightGray.cgColor
        userIdTextField.translatesAutoresizingMaskIntoConstraints = false
        let attributes = [
                   NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                   NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Medium", size: 15)!
               ]
        userIdTextField.attributedPlaceholder = NSAttributedString(string: "", attributes:attributes)
        userIdTextField.setLeftPaddingPoints(10)
        userIdTextField.setRightPaddingPoints(10)
        self.addSubview(userIdTextField)
        
        
        passwordLabel = UILabel(frame: CGRect.zero)
        passwordLabel.textColor = .black
        passwordLabel.text = "Password"
        passwordLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        passwordLabel.numberOfLines = 0
        passwordLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        passwordLabel.isUserInteractionEnabled = true
        passwordLabel.contentMode = UIView.ContentMode.topLeft
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.passwordLabel)
        passwordLabel.adjustsFontSizeToFitWidth = true
        passwordLabel.backgroundColor = .clear
        passwordLabel.layer.cornerRadius = 6.0
        passwordLabel.clipsToBounds = true
        passwordLabel.sizeToFit()
        
        passwordTextField = UITextField(frame: CGRect.zero)
        passwordTextField.borderStyle = .none
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        passwordTextField.text = ""
        passwordTextField.borderStyle = UITextField.BorderStyle.none
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 3
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "", attributes:attributes)
        passwordTextField.setLeftPaddingPoints(10)
        passwordTextField.setRightPaddingPoints(10)
        self.addSubview(passwordTextField)
        
        loginButton = UIButton(frame: CGRect.zero)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.clipsToBounds = true
        loginButton.backgroundColor = UIColor.init(red: 90/255, green: 154/255, blue: 197/255, alpha: 1.0)
        loginButton.layer.cornerRadius = 3
        loginButton.setTitleColor(Common.UIColorRGB(0xFFFFFF), for: .normal)
        loginButton.setTitle("Login", for: .normal)
        loginButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)!
        self.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(tapsOnLoginBtn), for: .touchUpInside)
        
        
        newUserLabel = UILabel(frame: CGRect.zero)
        newUserLabel.textColor = .black
        newUserLabel.text = "New User?"
        newUserLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
        newUserLabel.numberOfLines = 0
        newUserLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        newUserLabel.isUserInteractionEnabled = true
        newUserLabel.contentMode = UIView.ContentMode.topLeft
        newUserLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.newUserLabel)
        newUserLabel.adjustsFontSizeToFitWidth = true
        newUserLabel.backgroundColor = .clear
        newUserLabel.layer.cornerRadius = 6.0
        newUserLabel.clipsToBounds = true
        newUserLabel.sizeToFit()
        
        registerButton = UIButton(frame: CGRect.zero)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.clipsToBounds = true
        registerButton.backgroundColor = .clear
        registerButton.setTitleColor(UIColor.init(red: 90/255, green: 154/255, blue: 197/255, alpha: 1.0), for: .normal)
        registerButton.setTitle("Register here ▸", for: .normal)
        registerButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)!
        self.addSubview(registerButton)
        //registerButton.addTarget(self, action: #selector(tapsOnInlineFormBtn), for: .touchUpInside)
       
        forgotPasswordButton = UIButton(frame: CGRect.zero)
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.clipsToBounds = true
        forgotPasswordButton.backgroundColor = .clear
        forgotPasswordButton.setTitleColor(UIColor.init(red: 90/255, green: 154/255, blue: 197/255, alpha: 1.0), for: .normal)
        forgotPasswordButton.setTitle("Forgot password? ▸", for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)!
        self.addSubview(forgotPasswordButton)
        //forgotPasswordButton.addTarget(self, action: #selector(tapsOnInlineFormBtn), for: .touchUpInside)
        
        errorLabel = UILabel(frame: CGRect.zero)
        errorLabel.textColor = .red
        errorLabel.text = "Incorrect user Id/password"
        errorLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 15.0)
        errorLabel.numberOfLines = 0
        errorLabel.textAlignment = .center
        errorLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        errorLabel.isUserInteractionEnabled = true
        errorLabel.contentMode = UIView.ContentMode.topLeft
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.errorLabel)
        errorLabel.adjustsFontSizeToFitWidth = true
        errorLabel.backgroundColor = .clear
        errorLabel.layer.cornerRadius = 6.0
        errorLabel.clipsToBounds = true
        errorLabel.isHidden = true
        errorLabel.sizeToFit()
        
        let views: [String: UIView] = ["titleLbl": titleLbl, "userIdLabel": userIdLabel, "userIdTextField": userIdTextField, "passwordLabel": passwordLabel, "passwordTextField": passwordTextField, "loginButton": loginButton, "newUserLabel": newUserLabel, "registerButton": registerButton, "forgotPasswordButton":forgotPasswordButton, "errorLabel": errorLabel]
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[titleLbl(21)]-15-[userIdLabel(21)]-8-[userIdTextField(40)]-15-[passwordLabel(21)]-8-[passwordTextField(40)]-20-[loginButton(40)]-15-[newUserLabel(21)]-5-[errorLabel(21)]", options: [], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[titleLbl(21)]-15-[userIdLabel(21)]-8-[userIdTextField(40)]-15-[passwordLabel(21)]-8-[passwordTextField(40)]-20-[loginButton(40)]-10-[registerButton(30)]", options: [], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[titleLbl(21)]-15-[userIdLabel(21)]-8-[userIdTextField(40)]-15-[passwordLabel(21)]-8-[passwordTextField(40)]-20-[loginButton(40)]-10-[forgotPasswordButton(30)]", options: [], metrics: nil, views: views))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLbl]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[userIdLabel]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[userIdTextField]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[passwordLabel]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[passwordTextField]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[loginButton]-15-|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[newUserLabel(80)]-5-[registerButton(115)]-5-[forgotPasswordButton(150)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[errorLabel]-15-|", options: [], metrics: nil, views: views))
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @objc func tapsOnLoginBtn(_ sender:UIButton) {
        if userIdTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            errorLabel.text = "Please enter user Id/password"
            errorLabel.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
               // TODO: - whatever you want
                self.errorLabel.isHidden = true
            }
        }
        else if userIdTextField.text != "John" || passwordTextField.text != "1111"{
            errorLabel.text = "Incorrect user Id/password"
            errorLabel.isHidden = false
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
               // TODO: - whatever you want
                self.errorLabel.isHidden = true
            }
        }
        else if userIdTextField.text == "John" && passwordTextField.text == "1111"{
            userIdTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            print("Sucess")
            userIdTextField.text = ""
            passwordTextField.text = ""
            passwordTextField.resignFirstResponder()
            delegate?.LoginViewSucess()
        }
    }
    
   

}
extension LoginView: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            return false
        }
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        return newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
