import UIKit

func SetupNavigationBarApparence() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    
    //MARK: GRADIENT BACKGROUND
    // Create the gradient
    let gradient = CAGradientLayer()
    gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 500)
    gradient.colors = [
        UIColor.background.cgColor,
        UIColor.background.withAlphaComponent(0).cgColor
    ]
    
    // Render the gradient to an image
    UIGraphicsBeginImageContext(gradient.frame.size)
    gradient.render(in: UIGraphicsGetCurrentContext()!)
    let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // Apply the gradient to the NavigationBar and remove border
    appearance.backgroundImage = backgroundImage
    appearance.shadowColor = .clear
    
    //MARK: TEXT SETUP
    // Apply text color
    appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    
    //MARK: APPLY NAVIGATIONBAR MODIFICATION
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().tintColor = .white
}
