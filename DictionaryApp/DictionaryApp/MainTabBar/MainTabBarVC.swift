//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Nassyrkhan Seitzhapparuly on 7/9/19.
//  Copyright © 2019 Nassyrkhan Seitzhapparuly. All rights reserved.
//

import UIKit

class MainTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupTabBar()
    }

    private func setupTabBar() {
        tabBar.barTintColor = UIColor.white
        tabBar.tintColor = UIColor(red: 0/255, green: 164/255, blue: 215/255, alpha: 1)
        tabBar.unselectedItemTintColor = UIColor.black
        
        viewControllers = [
            createVC(vc: SavedVC(), image: UIImage(named: "tabBarBookmark") ?? UIImage(), selectedImage: UIImage(named: "tabBarBookmark-filled") ?? UIImage(), tag: 0),
            createVC(vc: SearchVC(), image: UIImage(named: "tabBarSearch") ?? UIImage(), selectedImage: UIImage(named: "tabBarSearch-filled") ?? UIImage(), tag: 1),
            createVC(vc: SettingsVC(), image: UIImage(named: "tabBarSettings") ?? UIImage(), selectedImage: UIImage(named: "tabBarSettings-filled") ?? UIImage(), tag: 2)
        ]
    }
    
    private func createVC(vc: UIViewController, image: UIImage, selectedImage: UIImage, tag: Int) -> UINavigationController {
        vc.tabBarItem.tag = tag        
        let navContoller = UINavigationController(rootViewController: vc)
        navContoller.tabBarItem = UITabBarItem(title: nil, image: image, selectedImage: selectedImage)
        navContoller.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        return navContoller
    }

}

