//
//  Fonts.swift
//  FitTime
//
//  Created by Francis Bato on 2/2/19.
//  Copyright © 2019 LateRisers. All rights reserved.
//

import UIKit

class Fonts {


    enum Mode: Int {
        case dark
        case light
    }

    enum FontFamily: String {
        case questrialRegular = "Questrial-Regular"
        case rubikItalic = "Rubik-Italic"
        case rubikRegular = "Rubik-Regular"
        case rubikBold = "Rubik-Bold"
        case rubikMediumItalic = "Rubik-MediumItalic"
        case rubikMedium = "Rubik-Medium"
        case rubikBoldItalic = "Rubik-BoldItalic"
        case rubikBlackItalic = "Rubik-BlackItalic"
        case rubikLightItalic = "Rubik-LightItalic"
        case rubikBlack = "Rubik-Black"
        case rubikLight = "Rubik-Light"
    }

    static func fontMapping(for style: UIFont.TextStyle, and mode: Fonts.Mode) -> (name: String, size: CGFloat) {
        switch mode {
        case .dark:
            if style == UIFont.TextStyle.title1 {
                return (FontFamily.rubikLight.rawValue, 34.0)
            } else if style == UIFont.TextStyle.title2  {
                return (FontFamily.questrialRegular.rawValue, 28.0)
            } else if style == UIFont.TextStyle.title3 {
                return (FontFamily.rubikRegular.rawValue, 24.0)
            } else if style == UIFont.TextStyle.largeTitle {
                return (FontFamily.questrialRegular.rawValue, 50.0)
            } else if style == UIFont.TextStyle.headline {
                return (FontFamily.rubikMedium.rawValue, 30.0)
            } else if style == UIFont.TextStyle.subheadline {
                return (FontFamily.rubikRegular.rawValue, 13.0)
            } else if style == UIFont.TextStyle.body {
                return (FontFamily.rubikRegular.rawValue, 15.0)
            } else if style == UIFont.TextStyle.callout {
                return (FontFamily.rubikMedium.rawValue, 15.0)
            } else if style == UIFont.TextStyle.footnote {
                return (FontFamily.rubikLight.rawValue, 14.0)
            }  else if style == UIFont.TextStyle.caption1 {
                return (FontFamily.rubikRegular.rawValue, 13.0)
            } else if style == UIFont.TextStyle.caption2 {
                return (FontFamily.questrialRegular.rawValue, 12.0)
            }
        case .light:
            if style == UIFont.TextStyle.title1 {
                return (FontFamily.questrialRegular.rawValue, 34.0)
            } else if style == UIFont.TextStyle.title2  {
                return (FontFamily.questrialRegular.rawValue, 28.0)
            } else if style == UIFont.TextStyle.title3 {
                return (FontFamily.rubikRegular.rawValue, 24.0)
            } else if style == UIFont.TextStyle.largeTitle {
                return (FontFamily.questrialRegular.rawValue, 50.0)
            } else if style == UIFont.TextStyle.headline {
                return (FontFamily.rubikMedium.rawValue, 30.0)
            } else if style == UIFont.TextStyle.subheadline {
                return (FontFamily.rubikRegular.rawValue, 13.0)
            } else if style == UIFont.TextStyle.body {
                return (FontFamily.rubikRegular.rawValue, 15.0)
            } else if style == UIFont.TextStyle.callout {
                return (FontFamily.rubikMedium.rawValue, 15.0)
            } else if style == UIFont.TextStyle.footnote {
                return (FontFamily.rubikLight.rawValue, 14.0)
            }  else if style == UIFont.TextStyle.caption1 {
                return (FontFamily.rubikRegular.rawValue, 13.0)
            } else if style == UIFont.TextStyle.caption2 {
                return (FontFamily.questrialRegular.rawValue, 12.0)
            }
        }
        return ("", 0.0)
    }

    static func attributes(for font: UIFont) -> [NSAttributedStringKey : Any] {
        return [NSAttributedStringKey.font : font]
    }

    static func getScaledFont(textStyle: UIFontTextStyle, mode: Fonts.Mode) -> UIFont {
        let (font, size) = Fonts.fontMapping(for: textStyle, and: mode)
        guard let customFont = UIFont(name: font, size: size) else {
            fatalError("""
                Failed to load the "\(font)" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        return UIFontMetrics.default.scaledFont(for: customFont)
    }

    static func printFonts() {
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
    }
}

@IBDesignable
class FTLabel: UILabel {
    enum Styles: String {
        case largeTitle = "UICTFontTextStyleLargeTitle"
        case title1 = "UICTFontTextStyleTitle1"
        case title2 = "UICTFontTextStyleTitle2"
        case title3 = "UICTFontTextStyleTitle3"
        case headline = "UICTFontTextStyleHeadline"
        case subheadline = "UICTFontTextStyleSubheadline"
        case body = "UICTFontTextStyleBody"
        case callout = "UICTFontTextStyleCallout"
        case footnote = "UICTFontTextStyleFootnote"
        case caption1 = "UICTFontTextStyleCaption1"
        case caption2 = "UICTFontTextStyleCpation2"

        static func styleForInt(input: Int) -> Styles {
            switch input {
            case 0:
                return .largeTitle
            case 1:
                return .title1
            case 2:
                return .title2
            case 3:
                return .title3
            case 4:
                return .headline
            case 5:
                return .subheadline
            case 6:
                return .body
            case 7:
                return .callout
            case 8:
                return .footnote
            case 9:
                return .caption1
            case 10:
                return caption2
            default:
                return .body
            }
        }

        static func rawValueFor(style: UIFontTextStyle) -> Int {
            if style == UIFont.TextStyle.largeTitle {
                return 0
            }else if style == UIFont.TextStyle.title1 {
                return 1
            } else if style == UIFont.TextStyle.title2  {
                return 2
            } else if style == UIFont.TextStyle.title3 {
                return 3
            } else if style == UIFont.TextStyle.headline {
                return 4
            } else if style == UIFont.TextStyle.subheadline {
                return 5
            } else if style == UIFont.TextStyle.body {
                return 6
            } else if style == UIFont.TextStyle.callout {
                return 7
            } else if style == UIFont.TextStyle.footnote {
                return 8
            }  else if style == UIFont.TextStyle.caption1 {
                return 9
            } else if style == UIFont.TextStyle.caption2 {
                return 10
            }

            return 0
        }
    }

    @IBInspectable var styleAdapter: Int {
        get {
            if let font = font.fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.textStyle) as? UIFontTextStyle {
                return Styles.rawValueFor(style: font)
            }

            return 0
        }

        set(sa) {
            guard let m = Fonts.Mode(rawValue: mode.rawValue) else { return }
            let st = UIFontTextStyle(Styles.styleForInt(input: sa).rawValue)
            font = Fonts.getScaledFont(textStyle: st, mode: m)
        }
    }

    @IBInspectable var modeAdapter: Int {
        get {
            return mode.rawValue
        }

        set(ma) {
            guard let m = Fonts.Mode(rawValue: ma) else {
                return
            }

            mode = m
        }
    }

    var mode: Fonts.Mode = .light

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    func setup() {
        adjustsFontForContentSizeCategory = true
        let st = UIFontTextStyle(Styles.styleForInt(input: styleAdapter).rawValue)
        font = Fonts.getScaledFont(textStyle: st, mode: mode)
        sizeToFit()
    }
}
