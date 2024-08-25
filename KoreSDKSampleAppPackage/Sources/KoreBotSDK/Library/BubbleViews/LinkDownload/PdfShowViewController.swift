//
//  PdfShowViewController.swift
//  KoreBotSDKDemo
//
//  Created by Kartheek.Pagidimarri on 14/03/22.
//  Copyright © 2022 Kore. All rights reserved.
//

import UIKit
import PDFKit
@available(iOS 11.0, *)
class PdfShowViewController: UIViewController {
    let bundle = Bundle(for: PdfShowViewController.self)
    @IBOutlet weak var titleLbl: UILabel!
    var pdfUrl:URL?
    var pdfView = PDFView()
    var dataString: String!
    
    @IBOutlet var closeBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(pdfView)
        //print("pdf url \(pdfUrl!)")
        
        let bundle = Bundle(for: PdfShowViewController.self)
        let menuImage = UIImage(named: "ic24Close", in: bundle, compatibleWith: nil)
        let tintedMenuImage = menuImage?.withRenderingMode(.alwaysTemplate)
        self.closeBtn.setImage(tintedMenuImage, for: .normal)
        self.closeBtn.tintColor = themeHighlightColor
        titleLbl.textColor = .black
        
        if let urlStr = pdfUrl?.absoluteURL{
            if #available(iOS 10.0, *) {
                do {
                    let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                    for url in contents {
                        if url.description.contains("\(urlStr)") {
                            // its your file! do what you want with it!
                            print("Got it")
                            if let document = PDFDocument(url: url){
                                pdfView.document = document
                                
                                pdfView.minScaleFactor = 0.1
                                pdfView.maxScaleFactor = 5

                                pdfView.autoScales = true
                                pdfView.displayMode = .singlePageContinuous
                                pdfView.displayDirection = .vertical
                                
                                let fileName = pdfUrl?.absoluteString
                                let fileArray = fileName?.components(separatedBy: "/")
                                let finalFileName = fileArray?.last
                                titleLbl.text = finalFileName
                                titleLbl.font = UIFont(name: mediumCustomFont, size: 14.0)
                            }
                            self.view.backgroundColor = BubbleViewLeftTint
                        }
                    }
                } catch {
                    print("could not locate pdf file !!!!!!!")
                }
            }
        }
        
        
    }
    
    
    init(dataString: String) {
        super.init(nibName: "PdfShowViewController", bundle: bundle)
        self.dataString = dataString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        pdfView.frame = CGRect(x: self.view.frame.origin.x, y: 100, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    
    @IBAction func tapsOnCloseBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
