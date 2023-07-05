# Kore Bot SDK
Kore offers Bots SDKs as a set of platform-specific client libraries that provide a quick and convenient way to integrate Kore Bots chat capability into custom applications.

With just few lines of code, you can embed our Kore chat widget into your applications to enable end-users to interact with your applications using Natural Language. For more information, refer to https://developer.kore.ai/docs/bots/kore-web-sdk/ 

# Kore Bot SDK for iOS developers

Kore Bot SDK for iOS enables you to talk to Kore bots over a web socket. This repo also comes with the code for sample application that developers can modify according to their Bot configuration.

# Setting up
### Prerequisites
* Service to generate JWT (JSON Web Tokens)- SDK uses this to send the user identity to Kore Platform.
* SDK app credentials 
    * Login to the Bots platform
    * Navigate to the Bot builder
    * Search and click on the bot 
    * Go to channels
    * Enable *Web / Mobile Client* channel against the bot as shown in the screen below.    
    ![Add bot to Web/Mobile Client channel](https://github.com/Koredotcom/iOS-kore-sdk/blob/master/channels.png)
    
    * create new or use existing SDK app to obtain client id and client secret
    ![Obtain Client id and Client secret](https://github.com/Koredotcom/iOS-kore-sdk/blob/master/web-mobile-client-channel.png)

## Instructions

### Configuration changes

* Setting up clientId, clientSecret, botId, chatBotName and identity in WidgetSDK/WidgetSDKConfiguration.swift
![SDKConfiguration setup](https://github.com/Koredotcom/iOS-kore-sdk/blob/master/sdk_configuration.png)

Client id - Copy this id from Bot Builder SDK Settings ex. cs-5250bdc9-6bfe-5ece-92c9-ab54aa2d4285
 ```
 static let clientId = "<client-id>"
 ```

Client secret - copy this value from Bot Builder SDK Settings ex. Wibn3ULagYyq0J10LCndswYycHGLuIWbwHvTRSfLwhs=
 ```
static let clientSecret = "<client-secret>"
 ```

User identity - this should represent the subject for JWT token that could be an email or phone number in case of known user. In case of anonymous user, this can be a randomly generated unique id.
 ```
static let identity = "<user@example.com>"
 ```

Bot name - copy this value from Bot Builder -> Channels -> Web/Mobile SDK config  ex. "Demo Bot"
 ```
static let chatBotName = "<bot-name>"
 ```

Bot Id - copy this value from Bot Builder -> Channels -> Web/Mobile SDK config  ex. st-acecd91f-b009-5f3f-9c15-7249186d827d
 ```
static let botId = "<bot-id>"
 ```

WIDGET_SERVER URL- replace it with your server URL, if required
 ```
static let WIDGET_SERVER = "https://bots.kore.ai";
 ```


JWT_SERVER URL - specify the server URL for JWT token generation. This token is used to authorize the SDK client. Refer to documentation on how to setup the JWT server for token generation - e.g. https://jwt-token-server.example.com/
 ```
static let JWT_SERVER = "<jwt-token-server-url>";
```

## Running the Demo app
#### a. Using Cocoa Pods
    * Download or clone the repository.
    * Run "pod install" in the Examples/CocoapodsDemo project folder.
    * Open Examples/CocoapodsDemo/KoreBotSDKDemo.xcworkspace in Xcode.
    * Run the KoreBotSDKDemo.app in xcode


## Integrating into your app
#### 1. Setup WidgetSDK
###### a. Using CocoaPods
    Add the following to your Podfile:
    pod 'WidgetSDK', :git => 'https://github.com/Koredotcom/iOS-kore-sdk.git’, :branch => 'WidgetSDK'
    
    Run pod install in your project folder.
    
#### 2. Initializing the Widget SDK in your Viewcontroller
    import WidgetSDK
    
    var panelCollectionViewContainerView: UIView!
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
    public var panelHeight: CGFloat {
        var maxHeight = maxPanelHeight
        maxHeight -= panelCollectionViewContainerView.bounds.height - insets.bottom - insets.top + 25.0
        return maxHeight
    }
    let widgetConnect = WidgetConnect()
    var widegtView: WidegtView!

#### 3. Add WidgetSDKDelegate 

    extension ViewController: WidgetViewDelegate{
    func configureWidgetView(){
        panelCollectionViewContainerView = UIView()
        panelCollectionViewContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(panelCollectionViewContainerView)
        panelCollectionViewContainerView.backgroundColor = .lightGray
        NSLayoutConstraint.activate([
            panelCollectionViewContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            panelCollectionViewContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelCollectionViewContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelCollectionViewContainerView.heightAnchor.constraint(equalToConstant: 55.0)
        ])
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
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            let safeAreaBottom =  CGFloat(keyWindow?.safeAreaInsets.bottom ?? 0.0)
            var inputViewHeight = safeAreaBottom
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

#### 4. Configuration changes in your Viewcontroller

        WidgetSDKConfiguration.widgetConfig.clientId =  "<client-id>"
        WidgetSDKConfiguration.widgetConfig.clientSecret = "<client-secret>"
        WidgetSDKConfiguration.widgetConfig.botId = "<bot-id>"
        WidgetSDKConfiguration.widgetConfig.chatBotName = "<bot-name>"
        WidgetSDKConfiguration.widgetConfig.identity = "<identity-email> or <random-id>"
        WidgetSDKConfiguration.widgetConfig.isAnonymous = true
        WidgetSDKConfiguration.serverConfig.JWT_SERVER = "http://<jwt-server-host>/"
        WidgetSDKConfiguration.serverConfig.WIDGET_SERVER = "https://bots.kore.ai"

#### 4. Connect with WidgetSDK

    widgetConnect.show(WidgetSDKConfiguration.widgetConfig.clientId) { statusStr in
            self.configureWidgetView()
        } failure: { error in
            print(error)
            let title = "Widget SDK Demo"
            let message = "YOU MUST SET WIDGET 'clientId', 'clientSecret', 'chatBotName', 'identity' and 'botId'. Please check the documentation."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }

#### 
    
License
----
Copyright © Kore, Inc. MIT License; see LICENSE for further details.
