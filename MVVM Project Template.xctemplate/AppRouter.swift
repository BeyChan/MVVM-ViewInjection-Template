//
//  AppRouter.swift
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright © ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Swinject

final class AppRouter {
    
    static let shared = AppRouter()

    // MARK: - Properties

    private let container = AppContainer()
    private var coordinator: Coordinator?

    // MARK: - Views

    private(set) var window: AppWindow?

    // MARK: - Init

    private init() {
        container.registerManagers()
        container.registerViewModels()
        container.registerControllers()
    }

    // MARK: - Methods
    
    func start(with options: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        window = AppWindow(frame: UIScreen.main.bounds)
        let vc = TabBarController(viewControllers: [NavigationController(rootViewController: DevVC()), NavigationController(rootViewController: DevVC()), DevVC()])
        vc.transitionAnimatorType = TabBarControllerTransitionAnimator.self
        window?.rootViewController = vc //container.resolve(DispatchController.self)!
        window?.makeKeyAndVisible()
    }

    func showProgressHUD() {
        window?.isActivityIndicatorVisible = true
    }

    func dismissProgressHUD() {
        window?.isActivityIndicatorVisible = false
    }
    
    func navigate(to route: Route, animated: Bool = true, completion: (() -> Void)? = nil) {
        handleCoordination(of: route, animated: animated, completion: completion)
    }

    private func handleCoordination(of route: Route, animated: Bool, completion: (() -> Void)?) {
        assert(Thread.isMainThread)
        switch route {
        case let authRoute as AuthRoute:
            if let router = coordinator as? AuthCoordinator {
                router.navigate(to: authRoute)
            } else {
                let authRouter = AuthCoordinator(initialRoute: authRoute, in: container)
                coordinator = authRouter
                window?.switchRootViewController(authRouter.mainController)
            }
        default:
            Log.error("Failed to resolve destination for route: \(route)")
        }
    }
}
