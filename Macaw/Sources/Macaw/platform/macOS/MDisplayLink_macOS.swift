//
//  MDisplayLink_macOS.swift
//  Macaw
//
//  Created by Daniil Manin on 8/17/17.
//  Copyright © 2017 Exyte. All rights reserved.
//

import Foundation

#if os(OSX)
import AppKit

public class MDisplayLink: MDisplayLinkProtocol {
    private var displayLink: CVDisplayLink?
    private var onUpdate: (() -> Void)?

    // MARK: - Lifecycle
    deinit {
        stop()
    }

    // MARK: - MDisplayLinkProtocol
    func startUpdates(_ onUpdate: @escaping () -> Void) {
        self.onUpdate = onUpdate

        if CVDisplayLinkCreateWithActiveCGDisplays(&displayLink) != kCVReturnSuccess {
            return
        }

        CVDisplayLinkSetOutputCallback(displayLink!, { _, _, _, _, _, userData -> CVReturn in

            let `self` = unsafeBitCast(userData, to: MDisplayLink.self)
            `self`.onUpdate?()

            return kCVReturnSuccess
        }, Unmanaged.passUnretained(self).toOpaque())

        if displayLink != nil {
            CVDisplayLinkStart(displayLink!)
        }
    }

    func invalidate() {
        stop()
    }

    private func stop() {
        if displayLink != nil {
            CVDisplayLinkStop(displayLink!)
        }
    }
}

#endif
