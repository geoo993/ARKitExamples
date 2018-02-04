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
            NSAttributedStringKey.strokeColor : borderColor,
            NSAttributedStringKey.foregroundColor : textColor,
            NSAttributedStringKey.strokeWidth : -borderWidth,
            NSAttributedStringKey.font : font
            ] 
    }
    
    public func addBorderOnLargeTitle(with textColor: UIColor, font: UIFont, borderWidth: CGFloat, borderColor: UIColor) {
        //Navigation Bar text
        self.largeTitleTextAttributes = [
            NSAttributedStringKey.strokeColor : borderColor,
            NSAttributedStringKey.foregroundColor : textColor,
            NSAttributedStringKey.strokeWidth : -borderWidth,
            NSAttributedStringKey.font : font
            ]
    }
    
    public var font : UIFont? {
        if let titleAttributes = self.titleTextAttributes {
            return titleAttributes[NSAttributedStringKey.font] as? UIFont 
        } else if let largeTitleAttributes = self.largeTitleTextAttributes {
            return largeTitleAttributes[NSAttributedStringKey.font] as? UIFont 
        } else {
            return nil
        }
    }
   
    public var color: UIColor? {
        
        if let titleAttributes = self.titleTextAttributes {
            return titleAttributes[NSAttributedStringKey.backgroundColor] as? UIColor 
        } else if let largeTitleAttributes = self.largeTitleTextAttributes {
            return largeTitleAttributes[NSAttributedStringKey.backgroundColor] as? UIColor 
        } else {
            return nil
        }
    }
    
    public var textColor: UIColor? {
        if let titleAttributes = self.titleTextAttributes {
            return titleAttributes[NSAttributedStringKey.foregroundColor] as? UIColor 
        } else if let largeTitleAttributes = self.largeTitleTextAttributes {
            return largeTitleAttributes[NSAttributedStringKey.foregroundColor] as? UIColor 
        } else {
            return nil
        }
    }
    
}
