//
//  MDisplayLink.swift
//  Pods
//
//  Created by Victor Sukochev on 28/08/2017.
//
//

import Foundation

protocol MDisplayLinkProtocol {
    func startUpdates(_ onUpdate: @escaping () -> Void)
    func invalidate()
}
