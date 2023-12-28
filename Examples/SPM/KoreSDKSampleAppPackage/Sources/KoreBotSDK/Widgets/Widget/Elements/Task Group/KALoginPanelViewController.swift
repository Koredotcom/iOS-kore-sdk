//
//  KALoginPanelViewController.swift
//  KoreBotSDK
//
//  Created by Sukhmeet Singh on 02/01/20.
//

import UIKit
import WebKit
import SafariServices
import MessageUI


open class KALoginPanelViewController: UIViewController {
    // MARK: - properties
   public var webView: WKWebView!
   public var urlStr: String?
   public var KALOADER_WIDTH = 20.0
   public var panelItem: KREPanelItem?
   let loaderView = KRELoaderView()
   public var safariViewController: SFSafariViewController?
    // MARK: -
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loaderView.lineWidth = 2.0
        loaderView.tintColor = UIColor.lightRoyalBlue
        loaderView.frame = CGRect(x: Double(UIScreen.main.bounds.size.width / 2) - KALOADER_WIDTH / 2, y: Double(UIScreen.main.bounds.size.height / 2) - KALOADER_WIDTH / 2, width: KALOADER_WIDTH, height: KALOADER_WIDTH)
        navigationController?.view.addSubview(loaderView)
        navigationController?.view.bringSubviewToFront(loaderView)
        loaderView.startAnimation()

        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        if let urlString = urlStr {
            if let url = URL(string: urlString) {
                let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60.0)
                webView.load(request)
            }
        }
        view.addSubview(webView)
        
        let views: [String : Any] = ["webView": webView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[webView]|", options:[], metrics: nil, views:views))
        if #available(iOS 11.0, *) {
            let guide = view.safeAreaLayoutGuide
            webView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        } else {
            let standardSpacing: CGFloat = 0.0
            webView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor, constant: standardSpacing).isActive = true
        }
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[webView]|", options:[], metrics: nil, views:views))
        
        let urlString = ""
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60.0)
            webView.load(request)
        }
        
        let closeButtonImage: UIImage = UIImage(named: "close_gray_icon")!
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeButtonImage, style: .plain, target: self, action: #selector(dismissSkills))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.gunmetal
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - button actions
    @objc func dismissSkills() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadWidgets"), object: nil)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - WKNavigationDelegate
extension KALoginPanelViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loaderView.stopAnimation()
        loaderView.removeFromSuperview()
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
}

// MARK: - WKUIDelegate
extension KALoginPanelViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

// MARK: - WKScriptMessageHandler
extension KALoginPanelViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension KALoginPanelViewController: MFMailComposeViewControllerDelegate{
    // MARK: - MFMailComposeViewController delegate
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
