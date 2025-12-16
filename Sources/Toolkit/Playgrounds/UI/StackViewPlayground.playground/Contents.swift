//: A UIKit based Playground for presenting user interface
  
import UIKit
import Toolkit
import PlaygroundSupport

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        self.view = view
    }
    
    override func viewDidLoad() {
        let stackView = UIStackView()
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.anchorToSuperView()
        
        let label1 = UILabel()
        label1.text = "Line 1"
        stackView.addArrangedSubview(label1)
        let label2 = UILabel()
        label2.text = "Line 2"
        stackView.addArrangedSubview(label2)
        stackView.addArrangedSubview(UIView.emptyView())
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
