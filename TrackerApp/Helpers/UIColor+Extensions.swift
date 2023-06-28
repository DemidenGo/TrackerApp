//
//  UIColor+Extensions.swift
//  TrackerApp
//
//  Created by Юрий Демиденко on 14.03.2023.
//

import UIKit

extension UIColor {
    static var interfaceBlue: UIColor { UIColor(named: "InterfaceBlue") ?? .blue }
    static var backgroundColor: UIColor { UIColor(named: "BackgroundColor") ?? .systemGray5 }
    static var interfaceGray: UIColor { UIColor(named: "InterfaceGray") ?? .systemGray2 }
    static var interfaceLightGray: UIColor { UIColor(named: "InterfaceLightGray") ?? .systemGray4 }
    static var buttonRed: UIColor { UIColor(named: "ButtonRed") ?? .red }
    static let viewBackgroundColor = UIColor.systemBackground
    static let buttonColor = UIColor { traits in
        if traits.userInterfaceStyle == .light { return UIColor.black }
        return UIColor.white
    }
}

extension Decodable where Self: UIColor {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let components = try container.decode([CGFloat].self)
        self = Self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}

extension Encodable where Self: UIColor {
    public func encode(to encoder: Encoder) throws {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        var container = encoder.singleValueContainer()
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        try container.encode([r,g,b,a])
    }
}

extension UIColor: Codable { }
