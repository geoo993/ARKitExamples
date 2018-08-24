import Foundation

public extension UINavigationBar {
    
    public func clearNavigationBarBackground(with color: UIColor){
        self.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.shadowImage = UIImage()
        self.isTranslucent = true
        self.backgroundColor = color
        
    }
    
    public func addBorderOnTitle(with textColor: UIColor, font: UIFont, borderWidth: CGFloat, borderColor: UIColor) {
        //Navigation Bar text
        self.titleTextAttributes = [
            NSAttributedString.Key.strokeColor : borderColor,
            NSAttributedString.Key.foregroundColor : textColor,
            NSAttributedString.Key.strokeWidth : -borderWidth,
            NSAttributedString.Key.font : font
            ] 
    }
    
    public func addBorderOnLargeTitle(with textColor: UIColor, font: UIFont, borderWidth: CGFloat, borderColor: UIColor) {
        //Navigation Bar text
        self.largeTitleTextAttributes = [
            NSAttributedString.Key.strokeColor : borderColor,
            NSAttributedString.Key.foregroundColor : textColor,
            NSAttributedString.Key.strokeWidth : -borderWidth,
            NSAttributedString.Key.font : font
            ]
    }
    
    public var font : UIFont? {
        if let titleAttributes = self.titleTextAttributes {
            return titleAttributes[NSAttributedString.Key.font] as? UIFont 
        } else if let largeTitleAttributes = self.largeTitleTextAttributes {
            return largeTitleAttributes[NSAttributedString.Key.font] as? UIFont 
        } else {
            return nil
        }
    }
   
    public var color: UIColor? {
        
        if let titleAttributes = self.titleTextAttributes {
            return titleAttributes[NSAttributedString.Key.backgroundColor] as? UIColor 
        } else if let largeTitleAttributes = self.largeTitleTextAttributes {
            return largeTitleAttributes[NSAttributedString.Key.backgroundColor] as? UIColor 
        } else {
            return nil
        }
    }
    
    public var textColor: UIColor? {
        if let titleAttributes = self.titleTextAttributes {
            return titleAttributes[NSAttributedString.Key.foregroundColor] as? UIColor 
        } else if let largeTitleAttributes = self.largeTitleTextAttributes {
            return largeTitleAttributes[NSAttributedString.Key.foregroundColor] as? UIColor 
        } else {
            return nil
        }
    }
    
}
