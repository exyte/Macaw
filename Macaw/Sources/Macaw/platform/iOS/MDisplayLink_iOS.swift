//
//  MDisplayLink_iOS.swift
//  Pods
//
//  Created by Victor Sukochev on 28/08/2017.
//
//

#if os(iOS)
import UIKit

class MDisplayLink: MDisplayLinkProtocol {
    private var displayLink: CADisplayLink?
    private var onUpdate: (() -> Void)?

    // MARK: - Lifecycle
    deinit {
        displayLink?.invalidate()
    }

    // MARK: - MDisplayLinkProtocol
    func startUpdates(_ onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate

        displayLink = CADisplayLink(target: self, selector: #selector(updateHandler))
        displayLink?.frameInterval = 1
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
    }

    func invalidate() {
        displayLink?.invalidate()
    }

    // MARK: - Private
    @objc func updateHandler() {
        onUpdate?()
    }
}
#endif
