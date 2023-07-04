//
//  ViewController.swift
//  WidgetDemoSDk
//
//  Created by Kartheek Pagidimarri on 27/06/23.
//

import UIKit
import AVFoundation
import WidgetSDK

class ViewController: UIViewController {

    @IBOutlet weak var panelCollectionViewContainerView: UIView!
    
    public var sheetController: KABottomSheetController?
    var insets: UIEdgeInsets = .zero
    public var maxPanelHeight: CGFloat {
        var maxHeight = UIScreen.main.bounds.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let delta: CGFloat = 15.0
        maxHeight -= statusBarHeight
        maxHeight -= delta
        return maxHeight
    }
    let widgetPanelTopSpace = 70.0
    public var panelHeight: CGFloat {
        var maxHeight = maxPanelHeight
        maxHeight -= panelCollectionViewContainerView.bounds.height - insets.bottom + widgetPanelTopSpace
        return maxHeight
    }
    
    let widgetConnect = WidgetConnect()
    var widegtView: WidegtView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        widgetConnect.show(WidgetSDKConfiguration.widgetConfig.clientId) { statusStr in
            self.configureInfoView()
        } failure: { error in
            print(error)
            let title = "Widget SDK Demo"
            let message = "YOU MUST SET WIDGET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}
extension ViewController: WidgetViewDelegate{
    func configureInfoView(){
        self.widegtView = WidegtView()
        self.widegtView.translatesAutoresizingMaskIntoConstraints = false
        self.widegtView.viewDelegate = self
        self.panelCollectionViewContainerView.addSubview(self.widegtView)
        self.panelCollectionViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[widegtView]|", options:[], metrics:nil, views:["widegtView" : widegtView!]))
        self.panelCollectionViewContainerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[widegtView]|", options:[], metrics:nil, views:["widegtView" : widegtView!]))
    }
    
    public func didselectWidegtView(item: WidgetSDK.KREPanelItem?){
        let weakSelf = self
        switch item?.type {
        case "action":
            processActionPanelItem(item)
        default:
            if #available(iOS 11.0, *) {
                self.insets = UIApplication.shared.delegate?.window??.safeAreaInsets ?? .zero
            }
            var inputViewHeight = 0.0
            inputViewHeight = inputViewHeight + (self.insets.bottom) + (self.panelCollectionViewContainerView.bounds.height)
            let sizes: [SheetSize] = [.fixed(0.0), .fixed(weakSelf.panelHeight)]
            if weakSelf.sheetController == nil {
                let panelItemViewController = KAPanelItemViewController()
                panelItemViewController.panelId = item?.id
                panelItemViewController.dismissAction = { [weak self] in
                    self?.sheetController = nil
                }
                self.view.endEditing(true)

                let bottomSheetController = KABottomSheetController(controller: panelItemViewController, sizes: sizes)
                bottomSheetController.inputViewHeight = CGFloat(inputViewHeight)
                bottomSheetController.willSheetSizeChange = { [weak self] (controller, newSize) in
                    switch newSize {
                    case .fixed(weakSelf.panelHeight):
                        controller.overlayColor = .clear
                        panelItemViewController.showPanelHeader(true)
                    default:
                        controller.overlayColor = .clear
                        panelItemViewController.showPanelHeader(false)
                        bottomSheetController.closeSheet(true)

                        self?.sheetController = nil
                    }
                }
                bottomSheetController.modalPresentationStyle = .overCurrentContext
                weakSelf.present(bottomSheetController, animated: true, completion: nil)
                weakSelf.sheetController = bottomSheetController
            } else if let bottomSheetController = weakSelf.sheetController,
                      let panelItemViewController = bottomSheetController.childViewController as? KAPanelItemViewController {
                panelItemViewController.panelId = item?.id

                if bottomSheetController.presentingViewController == nil {
                    weakSelf.present(bottomSheetController, animated: true, completion: nil)
                } else {
                    
                }
            }
        }
    }
    func processActionPanelItem(_ item: KREPanelItem?) {
        if let uriString = item?.action?.uri, let url = URL(string: uriString + "?teamId=59196d5a0dd8e3a07ff6362b") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
}
