//
//  Navigator.swift
//  Autonomy
//
//  Created by Anh Nguyen on 11/12/19.
//  Copyright © 2019 Bitmark Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Hero
import SafariServices
import BitmarkSDK

protocol Navigatable {
    var navigator: Navigator! { get set }
}

class Navigator {
    static var `default` = Navigator()

    // MARK: - segues list, all app scenes
    enum Scene {
        case launchingNavigation
        case main
    }

    enum Transition {
        case root(in: UIWindow)
        case navigation(type: HeroDefaultAnimationType)
        case customModal(type: HeroDefaultAnimationType)
        case replace(type: HeroDefaultAnimationType)
        case modal
        case detail
        case alert
        case custom
    }

    // MARK: - get a single VC
    func get(segue: Scene) -> UIViewController? {
        switch segue {
        case .launchingNavigation:
            let launchVC = LaunchingViewController()
            return NavigationController(rootViewController: launchVC)
        case .main:
            return nil
        }
    }

    func pop(sender: UIViewController?, toRoot: Bool = false) {
        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: true)
        } else {
            sender?.navigationController?.popViewController()
        }
    }

    func dismiss(sender: UIViewController?) {
        sender?.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - invoke a single segue
    func show(segue: Scene, sender: UIViewController?, transition: Transition = .navigation(type: .cover(direction: .left))) {
        if let target = get(segue: segue) {
            show(target: target, sender: sender, transition: transition)
        }
    }

    private func show(target: UIViewController, sender: UIViewController?, transition: Transition) {
        switch transition {
        case .root(in: let window):
            window.rootViewController = target
            return
        case .replace(let type):
            guard let rootViewController = Self.getRootViewController() else {
                Global.log.error("rootViewController is empty")
                return
            }

            // replace controllers in navigation stack
            rootViewController.hero.navigationAnimationType = .autoReverse(presenting: type)
            switch type {
            case .none:
                rootViewController.setViewControllers([target], animated: false)
            default:
                rootViewController.setViewControllers([target], animated: true)
            }
            return
        case .custom: return
        default: break
        }

        guard let sender = sender else {
            fatalError("You need to pass in a sender for .navigation or .modal transitions")
        }

        if let nav = sender as? UINavigationController {
            //push root controller on navigation stack
            nav.pushViewController(target, animated: false)
            return
        }

        switch transition {
        case .navigation(let type):
            if let nav = sender.navigationController {
                // push controller to navigation stack
                nav.hero.navigationAnimationType = .autoReverse(presenting: type)
                nav.pushViewController(target, animated: true)
            }
        case .customModal(let type):
            // present modally with custom animation
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                nav.hero.modalAnimationType = .autoReverse(presenting: type)
                sender.present(nav, animated: true, completion: nil)
            }
        case .modal:
            // present modally
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.present(nav, animated: true, completion: nil)
            }
        case .detail:
            DispatchQueue.main.async {
                let nav = NavigationController(rootViewController: target)
                sender.showDetailViewController(nav, sender: nil)
            }
        case .alert:
            DispatchQueue.main.async {
                sender.present(target, animated: true, completion: nil)
            }
        default: break
        }
    }

    static func getRootViewController() -> NavigationController? {
        return getWindow()?.rootViewController as? NavigationController
    }

    static func getWindow() -> UIWindow? {
        let window = UIApplication.shared.windows
            .filter { ($0.rootViewController as? NavigationController) != nil }
            .first

        window?.makeKeyAndVisible()
        return window
    }
}

enum ButtonItemType {
    case `continue`
    case back
    case none
}
