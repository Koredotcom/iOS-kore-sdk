import UIKit
//import React
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func BtnGoReactView(_ sender: Any) {
        let messageFromNative: String = textField.text!
        
        let rootView = RNViewManager.sharedInstance.viewForModule(
            "DemoIntegrateRN",
            initialProperties: ["message_from_native": messageFromNative])
        
        let reactNativeVC = UIViewController()
        reactNativeVC.view = rootView
        //reactNativeVC.modalPresentationStyle = .fullScreen
        //present(reactNativeVC, animated: true)
    
        let navigationController = UINavigationController(rootViewController: reactNativeVC)
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
