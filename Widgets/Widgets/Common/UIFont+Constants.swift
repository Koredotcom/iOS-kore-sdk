//
//  UIFont+Constants.swift
//  KoreBotSDK
//
//  Created by Srinivas Vasadi on 10/05/19.
//  Copyright © 2019 Srinivas Vasadi. All rights reserved.
//

import UIKit

extension UIFont {
    @objc public class func textFont(ofSize fontSize: CGFloat, weight: Weight = UIFont.Weight.regular) -> UIFont {
        let font: UIFont?
        let _ = KREFontLoader.shared
        switch weight {
        case .regular:
            font = UIFont(name: "Lato-Regular", size: fontSize)
        case .medium:
            font = UIFont(name: "Lato-Medium", size: fontSize)
        case .bold:
            font = UIFont(name: "Lato-Bold", size: fontSize)
        case .semibold:
            font = UIFont(name: "Lato-Semibold", size: fontSize)
        case .heavy:
            font = UIFont(name: "Lato-Heavy", size: fontSize)
        default:
            font = UIFont(name: "Lato-Regular", size: fontSize)
        }
        
        return font ?? UIFont.systemFont(ofSize: fontSize, weight: weight)
    }
    
    @objc public class func textItalicFont(ofSize fontSize: CGFloat) -> UIFont {
        let _ = KREFontLoader.shared
        let font = UIFont(name: "Lato-Italic", size: fontSize)
        return font ?? UIFont.italicSystemFont(ofSize: fontSize)
    }

    class func dynamicFontSizeAccordingToDeviceWidth(_ originalFontSize: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        //Reference width is of iPhoneXR :- 414
        let iPhoneXRWidth:CGFloat = 414.0
        let calculatedFontSize = screenWidth / iPhoneXRWidth * originalFontSize
        return calculatedFontSize
    }

    @objc public class func systemSymbolFont(ofSize fontSize: CGFloat) -> UIFont? {
        let font: UIFont?
        let _ = KREFontLoader.shared
        let newSize = dynamicFontSizeAccordingToDeviceWidth(fontSize)
        font = UIFont(name: "icomoon", size: newSize)
        return font
    }
}

// MARK: - KREFontLoader
public class KREFontLoader: NSObject {
    static var areFontsLoaded: Bool = false
    public static let shared = KREFontLoader()
    
    // MARK: - init
    override init() {
        super.init()
        loadLatoFonts()
        loadBebasNeueFonts()
        loadSystemSymbols()
    }
    
    func loadLatoFonts() {
        let bundleName = "Lato"
        guard let bundleUrl = Bundle(for: KREFontLoader.self).url(forResource: bundleName, withExtension: "bundle"),
            let bundle = Bundle(url: bundleUrl),
            let urls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else {
                return
        }
        
        for url in urls {
            loadFontFile(from: url)
        }
    }
    
    func loadSystemSymbols() {
        let bundleName = "Symbols"
        guard let bundleUrl = Bundle(for: KREFontLoader.self).url(forResource: bundleName, withExtension: "bundle") else {
            return
        }
        guard let bundle = Bundle(url: bundleUrl) else {
            return
        }
        guard let urls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else {
            return
        }
        
        for url in urls {
            loadFontFile(from: url)
        }
    }
    
    func loadBebasNeueFonts() {
        let bundleName = "BebasNeue"
        guard let bundleUrl = Bundle(for: KREFontLoader.self).url(forResource: bundleName, withExtension: "bundle"),
            let bundle = Bundle(url: bundleUrl),
            let urls = bundle.urls(forResourcesWithExtension: "ttf", subdirectory: nil) else {
                return
        }
        
        for url in urls {
            loadFontFile(from: url)
        }
    }
    
    func loadFontFile(from fontUrl: URL) {
        debugPrint(fontUrl)
        guard let fontData = try? Data(contentsOf: fontUrl) else {
            return
        }
        
        guard let cfData = fontData as? CFData, let provider = CGDataProvider(data: cfData), let cgFont = CGFont(provider) else {
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(cgFont, &error) {
            debugPrint("KREFontLoader : error loading Font")
        }
    }
}

public extension String {
    public func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    public func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    public func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    public func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    public func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
}

@objc public class KREResourceLoader: NSObject {
    public static let shared = KREResourceLoader()
    
    // MARK: - init
    override init() {
        super.init()
    }
    
    @objc func resourceBundle() -> Bundle {
        let bundleName = "KoreBotSDK"
        let appBundle = Bundle(for: KREResourceLoader.self)
        if let bundleUrl = appBundle.url(forResource: bundleName, withExtension: "bundle"),
           let bundle = Bundle(url: bundleUrl) {
            return bundle
        } else {
            return appBundle
        }
    }
}
