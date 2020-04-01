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
        case signInWall
        case onboardingStep1
        case onboardingStep2
        case onboardingStep3
        case permission
        case riskLevel(viewModel: RiskLevelViewModel)
        case main(viewModel: MainViewModel)
        case healthSurvey
        case surveyHelp
        case surveySymptoms(viewModel: SurveySymptomsViewModel)
        case assistance(viewModel: AssistanceViewModel)
        case assistanceAskInfo(viewModel: AssistanceAskInfoViewModel)
        case reviewHelpRequest(viewModel: ReviewHelpRequestViewModel)
        case safariController(URL)
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
            let navigationController = NavigationController(rootViewController: launchVC)
            navigationController.isHeroEnabled = true
            return navigationController

        case .signInWall:                       return SignInWallViewController()
        case .onboardingStep1:                  return OnboardingStep1ViewController()
        case .onboardingStep2:                  return OnboardingStep2ViewController()
        case .onboardingStep3:                  return OnboardingStep3ViewController()
        case .permission:                       return PermissionViewController()
        case .riskLevel(let viewModel):         return RiskLevelViewController(viewModel: viewModel)
        case .main(let viewModel):              return MainViewController(viewModel: viewModel)
        case .healthSurvey:                     return HealthSurveyViewController()
        case .surveyHelp:                       return SurveyHelpViewController()
        case .surveySymptoms(let viewModel):    return SurveySymptomsViewController(viewModel: viewModel)
        case .assistance(let viewModel):        return AssistanceViewController(viewModel: viewModel)
        case .assistanceAskInfo(let viewModel): return AssistanceAskInfoViewController(viewModel: viewModel)
        case .reviewHelpRequest(let viewModel): return ReviewHelpRequestViewController(viewModel: viewModel)

        case .safariController(let url):
            let vc = SFSafariViewController(url: url)
            vc.hidesBottomBarWhenPushed = true
            return vc
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

extension Navigator {
    static func gotoHealthSurveyScreen() {
        Navigator.default.show(segue: .healthSurvey, sender: nil, transition: .replace(type: .none))
    }
}

enum ButtonItemType {
    case `continue`
    case back
    case next
    case done
    case plus
    case review
    case none
}
