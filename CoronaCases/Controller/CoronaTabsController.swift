//
//  CoronaTabsController.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 19.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import SwiftUI

class CoronaTabsController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let coronaVC = UINavigationController(rootViewController: CoronaCasesVC())
        coronaVC.tabBarItem = UITabBarItem(
                                title: "COVID-19 Cases",
                                image: UIImage(named: "virus-unselected"),
                                selectedImage: UIImage(named: "virus-selected"))
        
        self.viewControllers = [coronaVC]
    }
}

#if DEBUG
struct ViewControllerPreview: PreviewProvider {
    static var previews: some View { ViewControllerSwiftUI() }
    
    struct ViewControllerSwiftUI: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> CoronaTabsController {
            CoronaTabsController()
        }
        
        func updateUIViewController(_ uiViewController: CoronaTabsController, context: Context) {
            
        }
    }
}
#endif
