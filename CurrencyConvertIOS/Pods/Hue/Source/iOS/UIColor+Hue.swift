import UIKit

// MARK: - Color Builders

public extension UIColor {

  public static func hex(string: String) -> UIColor {
    var hex = string.hasPrefix("#")
      ? String(string.characters.dropFirst())
      : string

    guard hex.characters.count == 3 || hex.characters.count == 6
      else { return UIColor.whiteColor().colorWithAlphaComponent(0.0) }

    if hex.characters.count == 3 {
      for (index, char) in hex.characters.enumerate() {
        hex.insert(char, atIndex: hex.startIndex.advancedBy(index * 2))
      }
    }

    return UIColor(
      red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
      green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
      blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
  }

  public func colorWithMinimumSaturation(minSaturation: CGFloat) -> UIColor {
    var (hue, saturation, brightness, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
    getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

    return saturation < minSaturation
      ? UIColor(hue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha)
      : self
  }

  public func alpha(value: CGFloat) -> UIColor {
    return colorWithAlphaComponent(value)
  }
}

// MARK: - Helpers

public extension UIColor {

  public func hex(withPrefix withPrefix: Bool = true) -> String {
    var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)
    getRed(&r, green: &g, blue: &b, alpha: &a)

    let prefix = withPrefix ? "#" : ""

    return String(format: "\(prefix)%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
  }

  public var isDark: Bool {
    let RGB = CGColorGetComponents(CGColor)
    return (0.2126 * RGB[0] + 0.7152 * RGB[1] + 0.0722 * RGB[2]) < 0.5
  }

  public var isBlackOrWhite: Bool {
    let RGB = CGColorGetComponents(CGColor)
    return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91) || (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
  }
    
  public var isBlack: Bool {
    let RGB = CGColorGetComponents(CGColor)
    return (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
  }
    
  public var isWhite: Bool {
    let RGB = CGColorGetComponents(CGColor)
    return (RGB[0] > 0.91 && RGB[1] > 0.91 && RGB[2] > 0.91)
  }

  public func isDistinctFrom(color: UIColor) -> Bool {
    let bg = CGColorGetComponents(CGColor)
    let fg = CGColorGetComponents(color.CGColor)
    let threshold: CGFloat = 0.25
    var result = false

    if fabs(bg[0] - fg[0]) > threshold || fabs(bg[1] - fg[1]) > threshold || fabs(bg[2] - fg[2]) > threshold {
      if fabs(bg[0] - bg[1]) < 0.03 && fabs(bg[0] - bg[2]) < 0.03 {
        if fabs(fg[0] - fg[1]) < 0.03 && fabs(fg[0] - fg[2]) < 0.03 {
          result = false
        }
      }
      result = true
    }

    return result
  }

  public func isContrastingWith(color: UIColor) -> Bool {
    let bg = CGColorGetComponents(CGColor)
    let fg = CGColorGetComponents(color.CGColor)

    let bgLum = 0.2126 * bg[0] + 0.7152 * bg[1] + 0.0722 * bg[2]
    let fgLum = 0.2126 * fg[0] + 0.7152 * fg[1] + 0.0722 * fg[2]
    let contrast = bgLum > fgLum
      ? (bgLum + 0.05) / (fgLum + 0.05)
      : (fgLum + 0.05) / (bgLum + 0.05)

    return 1.6 < contrast
  }
    
}

// MARK: - Gradient

public extension Array where Element : UIColor {

  public func gradient(transform: ((inout gradient: CAGradientLayer) -> CAGradientLayer)? = nil) -> CAGradientLayer {
    var gradient = CAGradientLayer()
    gradient.colors = self.map { $0.CGColor }

    if let transform = transform {
      transform(gradient: &gradient)
    }

    return gradient
  }
}

// MARK: - Components

public extension UIColor {
    
  var redComponent : CGFloat {
    get {
      var r : CGFloat = 0
      self.getRed(&r, green: nil , blue: nil, alpha: nil)
      return r
    }
  }
  
  var greenComponent : CGFloat {
    get {
      var g : CGFloat = 0
      self.getRed(nil, green: &g , blue: nil, alpha: nil)
      return g
    }
  }
  
  var blueComponent : CGFloat {
    get {
      var b : CGFloat = 0
      self.getRed(nil, green: nil , blue: &b, alpha: nil)
      return b
    }
  }
  
  var alphaComponent : CGFloat {
    get {
      var a : CGFloat = 0
      self.getRed(nil, green: nil , blue: nil, alpha: &a)
      return a
    }
  }
}


// MARK: - Blending

public extension UIColor {
  
  /**adds hue, saturation, and brightness to the HSB components of this color (self)*/
  public func addHue(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) -> UIColor {
    var (oldHue, oldSat, oldBright, oldAlpha) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
    self.getHue(&oldHue, saturation: &oldSat, brightness: &oldBright, alpha: &oldAlpha)
    return UIColor(hue: oldHue + hue, saturation: oldSat + saturation, brightness: oldBright + brightness, alpha: oldAlpha + alpha)
  }
  
  /**adds red, green, and blue to the RGB components of this color (self)*/
  public func addRed(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
    var (oldRed, oldGreen, oldBlue, oldAlpha) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
    self.getRed(&oldRed, green: &oldGreen, blue: &oldBlue, alpha: &oldAlpha)
    return UIColor(red: oldRed + red, green: oldGreen + green, blue: oldBlue + blue, alpha: oldAlpha + alpha)
  }
  
  public func addHSB(color: UIColor) -> UIColor {
    var (h,s,b,a) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
    color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return self.addHue(h, saturation: s, brightness: b, alpha: 0)
  }
  
  public func addRGB(color: UIColor) -> UIColor {
    return self.addRed(color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0)
  }
    
  public func addHSBA(color: UIColor) -> UIColor {
    var (h,s,b,a) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
    color.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
    return self.addHue(h, saturation: s, brightness: b, alpha: a)
  }
  
  /**adds the rgb components of two colors*/
  public func addRGBA(color: UIColor) -> UIColor {
    return self.addRed(color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent)
  }
}
