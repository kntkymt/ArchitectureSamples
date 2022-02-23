//
//  Presentation.swift
//  VIPER
//
//  Created by kntk on 2022/02/23.
//

protocol Presentation: AnyObject {

    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewDidStop()
}
