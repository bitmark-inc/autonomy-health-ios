//
//  ThemeManager.swift
//  Autonomy
//
//  Created by Anh Nguyen on 10/18/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme

let globalStatusBarStyle = BehaviorRelay<UIStatusBarStyle>(value: .lightContent)
var themeService = ThemeType.currentThemeService(for: .unspecified)

struct OurTheme {
    static let horizontalPadding: CGFloat = 15
    static var paddingInset: UIEdgeInsets = {
        switch UIScreen.main.bounds.size.height {
        case let x where x <= 800:
            return UIEdgeInsets(top: 14, left: 15, bottom: 13, right: 15)
        default:
            return UIEdgeInsets(top: 14, left: 15, bottom: 23, right: 15)
        }
    }()

    static var paddingOverBottomInset = UIEdgeInsets(top: 14, left: 15, bottom: 0, right: 15)

    static let titleHeight: CGFloat = 0.23
}

enum ThemeStyle {
    case headerLineColor
    case headerColor
    case blackTextColor
    case concordTextColor
    case silverTextColor
    case silverC4TextColor
    case lightTextColor
    case separateTextColor
    case background
    case silverChaliceColor
    case textViewTextColor
}

protocol Theme {
    var headerLineColor:    UIColor { get }
    var headerColor:        UIColor { get }
    var blackTextColor:     UIColor { get }
    var concordTextColor:   UIColor { get }
    var silverTextColor:    UIColor { get }
    var silverC4TextColor:  UIColor { get }
    var lightTextColor:     UIColor { get }
    var separateTextColor:  UIColor { get }
    var separateTableColor: UIColor { get }
    var background:         UIColor { get }
    var mineShaftBackground:  UIColor { get }
    var silverChaliceColor: UIColor { get }
    var textViewTextColor:  UIColor { get }

    init(colorTheme: ColorTheme)
}

struct LightTheme: Theme {
    let headerLineColor     = UIColor(hexString: "#828180")!
    let headerColor         = UIColor(hexString: "#BFBFBF")!
    let blackTextColor      = UIColor.Material.black
    let concordTextColor    = UIColor(hexString: "#828180")!
    let silverTextColor     = UIColor(hexString: "#BFBFBF")!
    let silverC4TextColor   = UIColor(hexString: "#828180")!
    let lightTextColor      = UIColor.Material.white
    let separateTextColor   = UIColor(hexString: "#828180")!
    let separateTableColor  = UIColor(hexString: "#C4C4C4")!
    let background          = UIColor(hexString: "#000")!
    let mineShaftBackground   = UIColor(hexString: "#2B2B2B")!
    let silverChaliceColor  = UIColor(hexString: "#9E9E9E")!
    let textViewTextColor   = UIColor(hexString: "#FFF")!

    init(colorTheme: ColorTheme) {}
}

struct DarkTheme: Theme {
    let headerLineColor     = UIColor(hexString: "#828180")!
    let headerColor         = UIColor(hexString: "#BFBFBF")!
    let blackTextColor      = UIColor.Material.black
    let concordTextColor    = UIColor(hexString: "#828180")!
    let silverTextColor     = UIColor(hexString: "#BFBFBF")!
    let silverC4TextColor   = UIColor(hexString: "#C4C4C4")!
    let lightTextColor      = UIColor.Material.white
    let separateTextColor   = UIColor(hexString: "#828180")!
    let separateTableColor  = UIColor(hexString: "#828180")!
    let background          = UIColor(hexString: "#000")!
    let mineShaftBackground   = UIColor(hexString: "#2B2B2B")!
    let silverChaliceColor  = UIColor(hexString: "#9E9E9E")!
    let textViewTextColor   = UIColor(hexString: "#FFF")!

    init(colorTheme: ColorTheme) {}
}

enum ColorTheme: Int, CaseIterable {
    case red, pink, purple, deepPurple, indigo, blue, lightBlue, cyan, teal, green, lightGreen, lime, yellow, amber, orange, deepOrange, brown, gray, blueGray, black, white

    case silver

    var color: UIColor {
        switch self {
        case .red:        return UIColor.Material.red
        case .pink:       return UIColor.Material.pink
        case .purple:     return UIColor.Material.purple
        case .deepPurple: return UIColor.Material.deepPurple
        case .indigo:     return UIColor.Material.indigo
        case .blue:       return UIColor.Material.blue
        case .lightBlue:  return UIColor.Material.lightBlue
        case .cyan:       return UIColor.Material.cyan
        case .teal:       return UIColor.Material.teal
        case .green:      return UIColor.Material.green
        case .lightGreen: return UIColor.Material.lightGreen
        case .lime:       return UIColor.Material.lime
        case .yellow:     return UIColor.Material.yellow
        case .amber:      return UIColor.Material.amber
        case .orange:     return UIColor.Material.orange
        case .deepOrange: return UIColor.Material.deepOrange
        case .brown:      return UIColor.Material.brown
        case .gray:       return UIColor.Material.grey
        case .blueGray:   return UIColor.Material.blueGrey
        case .white:        return UIColor.white
        case .black:        return UIColor.black
        case .silver:      return UIColor(hexString: "#BFBFBF")!
        }
    }

    var colorDark: UIColor {
        switch self {
        case .red:        return UIColor.Material.red900
        case .pink:       return UIColor.Material.pink900
        case .purple:     return UIColor.Material.purple900
        case .deepPurple: return UIColor.Material.deepPurple900
        case .indigo:     return UIColor.Material.indigo900
        case .blue:       return UIColor.Material.blue900
        case .lightBlue:  return UIColor.Material.lightBlue900
        case .cyan:       return UIColor.Material.cyan900
        case .teal:       return UIColor.Material.teal900
        case .green:      return UIColor.Material.green900
        case .lightGreen: return UIColor.Material.lightGreen900
        case .lime:       return UIColor.Material.lime900
        case .yellow:     return UIColor.Material.yellow900
        case .amber:      return UIColor.Material.amber900
        case .orange:     return UIColor.Material.orange900
        case .deepOrange: return UIColor.Material.deepOrange900
        case .brown:      return UIColor.Material.brown900
        case .gray:       return UIColor.Material.grey900
        case .blueGray:   return UIColor.Material.blueGrey900
        case .white:      return UIColor.white
        case .black:      return UIColor.black
        case .silver:     return UIColor(hexString: "#BFBFBF")!
        }
    }

    var title: String {
        switch self {
        case .red:        return "Red"
        case .pink:       return "Pink"
        case .purple:     return "Purple"
        case .deepPurple: return "Deep Purple"
        case .indigo:     return "Indigo"
        case .blue:       return "Blue"
        case .lightBlue:  return "Light Blue"
        case .cyan:       return "Cyan"
        case .teal:       return "Teal"
        case .green:      return "Green"
        case .lightGreen: return "Light Green"
        case .lime:       return "Lime"
        case .yellow:     return "Yellow"
        case .amber:      return "Amber"
        case .orange:     return "Orange"
        case .deepOrange: return "Deep Orange"
        case .brown:      return "Brown"
        case .gray:       return "Gray"
        case .blueGray:   return "Blue Gray"
        case .white:        return "White"
        case .black:        return "Black"
        case .silver:       return "Silver"
        }
    }
}

enum ThemeType: ThemeProvider {
    case light(color: ColorTheme)
    case dark(color: ColorTheme)

    var associatedObject: Theme {
        switch self {
        case .light(let color): return LightTheme(colorTheme: color)
        case .dark(let color): return DarkTheme(colorTheme: color)
        }
    }

    var isDark: Bool {
        switch self {
        case .dark: return true
        default: return false
        }
    }

    func toggled() -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light(let color): theme = ThemeType.dark(color: color)
        case .dark(let color): theme = ThemeType.light(color: color)
        }
        return theme
    }

    func withColor(color: ColorTheme) -> ThemeType {
        var theme: ThemeType
        switch self {
        case .light: theme = ThemeType.light(color: color)
        case .dark: theme = ThemeType.dark(color: color)
        }
        theme.save()
        return theme
    }
}

extension ThemeService where Provider == ThemeType {
    func switchThemeType(for userStyle: UIUserInterfaceStyle) {
        let updateTheme = ThemeType.currentTheme(isDark: userStyle == .dark)
        self.switch(updateTheme)
    }
}

extension ThemeType {
    static func currentThemeService(for userStyle: UIUserInterfaceStyle) -> ThemeService<ThemeType> {
        let currentThemeForStyle = currentTheme(isDark: userStyle == .dark)
        return ThemeType.service(initial: currentThemeForStyle)
    }

    static func currentTheme(isDark: Bool) -> ThemeType {
        let defaults = UserDefaults.standard
        let colorTheme = ColorTheme(rawValue: defaults.integer(forKey: "ThemeKey")) ?? ColorTheme.red
        let theme = isDark ? ThemeType.dark(color: colorTheme) : ThemeType.light(color: colorTheme)
        theme.save()
        return theme
    }

    func save() {
        let defaults = UserDefaults.standard
        switch self {
        case .light(let color): defaults.set(color.rawValue, forKey: "ThemeKey")
        case .dark(let color): defaults.set(color.rawValue, forKey: "ThemeKey")
        }
    }
}

class Size {

    // dimention size
    static func ds(_ size: CGFloat) -> CGFloat {
        return (size / 414) * UIScreen.main.bounds.width
    }

    // dimention width
    static func dw(_ size: Int) -> CGFloat {
        let sizeFloat = CGFloat(size)
        return (sizeFloat / 414) * UIScreen.main.bounds.width
    }

    // dimention height
    static func dh(_ size: Int) -> CGFloat {
        let sizeFloat = CGFloat(size)
        return (sizeFloat / 896) * UIScreen.main.bounds.height
    }
}

class Avenir {
    static func size(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir", size: size)!
    }

    class Heavy {
        static func size(_ size: CGFloat) -> UIFont {
            return UIFont(name: "Avenir-Heavy", size: size)!
        }
    }
}

extension Reactive where Base: UIView {

    var backgroundColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.backgroundColor = attr
        }
    }

    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.borderColor = attr
        }
    }
}

extension Reactive where Base: UITextField {

    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.borderColor = attr
        }
    }

    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { textfield, attr in
            guard let color = attr else { return }
            textfield.setPlaceHolderTextColor(color)
        }
    }
}

extension Reactive where Base: UITableView {

    var separatorColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.separatorColor = attr
        }
    }
}

extension Reactive where Base: UINavigationBar {

    @available(iOS 11.0, *)
    var largeTitleTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        return Binder(self.base) { view, attr in
            view.largeTitleTextAttributes = attr
        }
    }
}

extension Reactive where Base: UIApplication {

    var statusBarStyle: Binder<UIStatusBarStyle> {
        return Binder(self.base) { _, attr in
            globalStatusBarStyle.accept(attr)
        }
    }
}

public extension Reactive where Base: UISwitch {

    var onTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.onTintColor = attr
        }
    }

    var thumbTintColor: Binder<UIColor?> {
        return Binder(self.base) { view, attr in
            view.thumbTintColor = attr
        }
    }
}
