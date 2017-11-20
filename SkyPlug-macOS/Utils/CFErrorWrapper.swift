//
//  CFErrorWrapper.swift
//  skyplug
//
//  Created by Ivan Brazhnikov on 20/11/2017.
//  Copyright © 2017 Ivan Brazhnikov. All rights reserved.
//

import Foundation

public  struct CFErrorWrapper: CustomNSError, LocalizedError {
  public let wrapped: CFError
  public static let errorDomain: String = "Core Foundation"
  public var errorCode: Int {
    return CFErrorGetCode(wrapped)
  }
  public var errorUserInfo: [String : Any] {
    return CFErrorCopyUserInfo(wrapped) as? [String : Any] ?? [:]
  }
  public var recoverySuggestion: String? {
    return CFErrorCopyRecoverySuggestion(wrapped) as String?
  }
  public var errorDescription: String? {
    return CFErrorCopyDescription(wrapped) as String?
  }
  public var failureReason: String? {
    return CFErrorCopyFailureReason(wrapped) as String?
  }
}

extension CFError {
  public func wrapping() -> CFErrorWrapper {
    return CFErrorWrapper(wrapped: self)
  }
}
