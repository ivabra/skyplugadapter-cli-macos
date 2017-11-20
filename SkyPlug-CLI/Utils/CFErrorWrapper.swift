//
//  CFErrorWrapper.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 20/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

struct CFErrorWrapper: CustomNSError, LocalizedError {
  let wrapped: CFError
  static let errorDomain: String = "Core Foundation"
  var errorCode: Int {
    return CFErrorGetCode(wrapped)
  }
  var errorUserInfo: [String : Any] {
    return CFErrorCopyUserInfo(wrapped) as? [String : Any] ?? [:]
  }
  var recoverySuggestion: String? {
    return CFErrorCopyRecoverySuggestion(wrapped) as String?
  }
  var errorDescription: String? {
    return CFErrorCopyDescription(wrapped) as String?
  }
  var failureReason: String? {
    return CFErrorCopyFailureReason(wrapped) as String?
  }
}

extension CFError {
  func wrapping() -> CFErrorWrapper {
    return CFErrorWrapper(wrapped: self)
  }
}
