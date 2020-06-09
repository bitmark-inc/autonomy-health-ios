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
        case youHealthDetails(viewModel: YouHealthDetailsViewModel)
        case placeHealthDetails(viewModel: PlaceHealthDetailsViewModel)
        case surveyHelp
        case surveySymptoms(viewModel: SurveySymptomsViewModel)
        case searchSymptom(viewModel: SearchSymptomViewModel)
        case reportedSymptoms(viewModel: ReportedSymptomViewModel)
        case symptomGuidance(viewModel: SymptomGuidanceViewModel)
        case surveyBehaviors(viewModel: SurveyBehaviorsViewModel)
        case searchBehavior(viewModel: SearchBehaviorViewModel)
        case reportedBehaviors(viewModel: ReportedBehaviorViewModel)
        case behaviorGuidance
        case assistance(viewModel: AssistanceViewModel)
        case assistanceAskInfo(viewModel: AssistanceAskInfoViewModel)
        case reviewHelpRequest(viewModel: ReviewHelpRequestViewModel)
        case giveHelp(viewModel: GiveHelpViewModel)
        case resourceRating(viewModel: ResourceRatingViewModel)
        case addResource(viewModel: AddResourceViewModel)
        case searchResource(viewModel: SearchResourceViewModel)
        case locationSearch(viewModel: LocationSearchViewModel)
        case profile
        case donate
        case viewRecoveryKeyWarning
        case viewRecoveryKey(viewModel: ViewRecoveryKeyViewModel)
        case symptomHistory(viewModel: SymptomHistoryViewModel)
        case behaviorHistory(viewModel: BehaviorHistoryViewModel)
        case locationHistory(viewModel: LocationHistoryViewModel)
        case debugLocation(viewModel: DebugLocationViewModel)
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
        case .youHealthDetails(let viewModel):     return YouHealthDetailsViewController(viewModel: viewModel)
        case .placeHealthDetails(let viewModel):   return PlaceHealthDetailsViewController(viewModel: viewModel)
        case .surveyHelp:                       return SurveyHelpViewController()
        case .surveySymptoms(let viewModel):    return SurveySymptomsViewController(viewModel: viewModel)
        case .searchSymptom(let viewModel):      return SearchSymptomViewController(viewModel: viewModel)
        case .reportedSymptoms(let viewModel):  return ReportedSymptomViewController(viewModel: viewModel)
        case .symptomGuidance(let viewModel):   return SymptomGuidanceViewController(viewModel: viewModel)
        case .surveyBehaviors(let viewModel):   return SurveyBehaviorsViewController(viewModel: viewModel)
        case .searchBehavior(let viewModel):      return SearchBehaviorViewController(viewModel: viewModel)
        case .reportedBehaviors(let viewModel):  return ReportedBehaviorViewController(viewModel: viewModel)
        case .behaviorGuidance:                 return BehaviorGuidanceViewController()
        case .assistance(let viewModel):        return AssistanceViewController(viewModel: viewModel)
        case .assistanceAskInfo(let viewModel): return AssistanceAskInfoViewController(viewModel: viewModel)
        case .reviewHelpRequest(let viewModel): return ReviewHelpRequestViewController(viewModel: viewModel)
        case .giveHelp(let viewModel):          return GiveHelpViewController(viewModel: viewModel)
        case .resourceRating(let viewModel):            return ResourceRatingViewController(viewModel: viewModel)
        case .addResource(let viewModel):       return AddResourceViewController(viewModel: viewModel)
        case .searchResource(let viewModel):    return SearchResourceVieController(viewModel: viewModel)
        case .locationSearch(let viewModel):    return LocationSearchViewController(viewModel: viewModel)
        case .profile:                          return ProfileViewController()
        case .donate:                           return DonateViewController()
        case .viewRecoveryKeyWarning:           return ViewRecoveryKeyWarningViewController()
        case .viewRecoveryKey(let viewModel):   return ViewRecoveryKeyViewController(viewModel: viewModel)
        case .symptomHistory(let viewModel):    return SymptomHistoryViewController(viewModel: viewModel)
        case .behaviorHistory(let viewModel):   return BehaviorHistoryViewController(viewModel: 
            viewModel)
        case .locationHistory(let viewModel):   return LocationHistoryViewController(viewModel: viewModel)
        case .debugLocation(let viewModel):     return DebugLocationViewController(viewModel: viewModel)

        case .safariController(let url):
            let vc = SFSafariViewController(url: url)
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }

    func pop(sender: UIViewController?, toRoot: Bool = false, animated: Bool = true, animationType: HeroDefaultAnimationType? = nil) {

        if let animationType = animationType {
            Self.getRootViewController()?.hero.navigationAnimationType = animationType
        }

        if toRoot {
            sender?.navigationController?.popToRootViewController(animated: animated)
        } else {
            sender?.navigationController?.popViewController(animated: animated)
        }
    }

    func popToViewController(target: UIViewController, animationType: HeroDefaultAnimationType) {
        guard let navVC = Self.getRootViewController() else { return }
        navVC.hero.navigationAnimationType = animationType
        navVC.popToViewController(target, animated: true)
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
            if let nav = sender.navigationController {
                nav.hero.modalAnimationType = .autoReverse(presenting: type)
                sender.present(target, animated: true, completion: nil)
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
        var window = UIApplication.shared.windows
            .filter { ($0.rootViewController as? NavigationController) != nil }
            .first

        if window == nil {
            window = UIApplication.shared.windows.first(where: { !$0.isHidden })
        }

        window?.makeKeyAndVisible()
        return window
    }
}

extension Navigator {
    static func goto(segue: Scene) {
        Global.log.info("[notification] move to Screen: \(segue)")
        guard let currentVC = Navigator.getRootViewController()?.topViewController else {
            guard let window = getWindow() else { return }
            Navigator.default.show(segue: .launchingNavigation, sender: nil, transition: .root(in: window))
            Navigator.default.show(segue: segue, sender: nil, transition: .replace(type: .none))
            return
        }

        Navigator.default.show(segue: segue, sender: currentVC)
    }

    static func gotoPOIScreen(poiID: String?) {
        Global.log.info("[notification] move to POI Screen: \(poiID ?? "nil")")
        if let currentVC = Navigator.getRootViewController()?.topViewController,
            let mainVC = currentVC as? MainViewController {
            // TODO: highlight POI?
            // mainVC.gotoPOI(with: poiID)
        }

        let viewModel = MainViewModel(navigateToPoiID: poiID)
        goto(segue: .main(viewModel: viewModel))
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
