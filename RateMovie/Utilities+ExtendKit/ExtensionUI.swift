//
//  ExtensionUI.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 06/10/22.
//

import UIKit

public struct RMColor {
    // MARK: - Dynamic Color Provider
    public static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return dark
        }
    }
    
    // MARK: - 1. Brand & Highlights (Midnight Ruby)
    public static let brandPrimary = dynamic(
        light: hexStringToUIColor(hex: "#D90429"),
        dark: hexStringToUIColor(hex: "#FF2A54")
    )
    
    public static let brandSecondary = dynamic(
        light: hexStringToUIColor(hex: "#FF4D6D"),
        dark: hexStringToUIColor(hex: "#FF6B8B")
    )
    
    // MARK: - 2. Accents
    public static let accentRating = dynamic(
        light: hexStringToUIColor(hex: "#F59E0B"),
        dark: hexStringToUIColor(hex: "#FFB703")
    )
    
    public static let accentFavorite = dynamic(
        light: hexStringToUIColor(hex: "#E11D48"),
        dark: hexStringToUIColor(hex: "#FF3366")
    )
    
    // MARK: - 3. Canvas & Backgrounds
    public static let backgroundPrimary = dynamic(
        light: hexStringToUIColor(hex: "#F6F7FB"),
        dark: hexStringToUIColor(hex: "#0D0E12")
    )
    
    public static let backgroundSecondary = dynamic(
        light: hexStringToUIColor(hex: "#EDF0F5"),
        dark: hexStringToUIColor(hex: "#14151B")
    )
    
    // MARK: - 4. Surfaces & Cards
    public static let surfaceCard = dynamic(
        light: hexStringToUIColor(hex: "#FFFFFF"),
        dark: hexStringToUIColor(hex: "#17181F")
    )
    
    public static let surfaceCardElevated = dynamic(
        light: hexStringToUIColor(hex: "#FFFFFF"),
        dark: hexStringToUIColor(hex: "#1F2029")
    )
    
    public static let surfaceBadge = dynamic(
        light: UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 0.06),
        dark: UIColor(white: 1.0, alpha: 0.08)
    )
    
    public static let surfaceGlass = dynamic(
        light: UIColor(white: 1.0, alpha: 0.88),
        dark: UIColor(red: 13/255, green: 14/255, blue: 18/255, alpha: 0.85)
    )
    
    // MARK: - 5. Typography
    public static let textPrimary = dynamic(
        light: hexStringToUIColor(hex: "#0F172A"),
        dark: hexStringToUIColor(hex: "#FFFFFF")
    )
    
    public static let textSecondary = dynamic(
        light: hexStringToUIColor(hex: "#475569"),
        dark: hexStringToUIColor(hex: "#9CA3AF")
    )
    
    public static let textTertiary = dynamic(
        light: hexStringToUIColor(hex: "#94A3B8"),
        dark: hexStringToUIColor(hex: "#6B7280")
    )
    
    // MARK: - 6. Borders & Dividers
    public static let borderSubtle = dynamic(
        light: UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 0.07),
        dark: UIColor(white: 1.0, alpha: 0.08)
    )
    
    public static let borderEmphasis = dynamic(
        light: UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 0.15),
        dark: UIColor(white: 1.0, alpha: 0.18)
    )
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
