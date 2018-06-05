//
//  Imag.swift
//  App
//
//  Created by Niklas Sauer on 23.05.18.
//

import Foundation
import Vapor
import RoadChatKit

struct Multipart: Content {
    let file: File
}

extension PublicFile: Content { }
