//
//  MDisplayLink_iOS.swift
//  Pods
//
//  Created by Victor Sukochev on 28/08/2017.
//
//

#if os(iOS) || os(tvOS)
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
            #if os(iOS)
                displayLink?.frameInterval = 1
            #elseif os(tvOS)
                displayLink?.preferredFramesPerSecond = 1
            #endif
            displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
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
