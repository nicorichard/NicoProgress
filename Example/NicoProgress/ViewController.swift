import UIKit
import NicoProgress

//MARK: - ViewController
internal class ViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet private weak var storyboardProgressBar: NicoProgressBar!
    @IBOutlet private weak var programmaticProgressBarContainer: UIView!
    @IBOutlet private weak var progressSlider: UISlider!
    @IBOutlet private weak var indeterminateSwitch: UISwitch!
    @IBOutlet private weak var indeterminateSwitchLabel: UILabel!
    @IBOutlet private weak var button: UIButton!

    @IBOutlet private weak var determinateZero: NicoProgressBar!
    @IBOutlet private weak var determinateFifty: NicoProgressBar!
    @IBOutlet private weak var determinateHundred: NicoProgressBar!

    //MARK: Properties
    private var programmaticProgressBar: NicoProgressBar!
    private var state: NicoProgressBarState = .indeterminate

    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()


        setupViewControllerPushBugTestButton()
        setupProgressSlider()
        setupProgrammaticProgressBar()
        setupDeterminateProgressBars()
        
        transition(to: state)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            // To animate during view creation we need to be async after view appears
            self.determinateZero.transition(to: .determinate(percentage: 0.25))
        }

    }
    
    //MARK: Setup
    private func setupProgressSlider() {
        progressSlider.isContinuous = false
    }

    private func setupViewControllerPushBugTestButton() {
        button.setTitle("Push VC", for: .normal)
    }

    private func setupDeterminateProgressBars() {
        determinateZero.transition(to: .determinate(percentage: 0))
        determinateFifty.transition(to: .determinate(percentage: 0.5))
        determinateHundred.transition(to: .determinate(percentage: 1))
    }
    
    private func setupProgrammaticProgressBar() {
        programmaticProgressBar = NicoProgressBar()
        programmaticProgressBar.primaryColor = .green
        programmaticProgressBar.secondaryColor = .red
        
        programmaticProgressBarContainer.addSubview(programmaticProgressBar)
        
        NSLayoutConstraint(item: programmaticProgressBar, attribute: .top, relatedBy: .equal, toItem: programmaticProgressBarContainer, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: programmaticProgressBar, attribute: .bottom, relatedBy: .equal, toItem: programmaticProgressBarContainer, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: programmaticProgressBar, attribute: .leading, relatedBy: .equal, toItem: programmaticProgressBarContainer, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: programmaticProgressBar, attribute: .trailing, relatedBy: .equal, toItem: programmaticProgressBarContainer, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
    }
    
    //MARK: Actions
    @IBAction func progressSliderValueChanged(_ sender: Any) {
        switch state {
            case .determinate(_):
                transition(to: .determinate(percentage: CGFloat(progressSlider.value)))
            case .indeterminate:
                break
        }
    }
    
    @IBAction func indeterminateSwitchValueChanged(_ sender: Any) {
        switch indeterminateSwitch.isOn {
            case true:
                transition(to: .indeterminate)
            case false:
                transition(to: .determinate(percentage: CGFloat(progressSlider.value)))
        }
    }
    
    //MARK: State
    internal func transition(to state: NicoProgressBarState) {
        self.state = state
        
        switch state {
            case .determinate(_):
                storyboardProgressBar.transition(to: state)
                programmaticProgressBar.transition(to: state)
                indeterminateSwitchLabel.text = NSLocalizedString("Determinate", comment: "")
            case .indeterminate:
                storyboardProgressBar.transition(to: state)
                programmaticProgressBar.transition(to: state)
                indeterminateSwitchLabel.text = NSLocalizedString("Indeterminate", comment: "")
        }
    }

    @IBAction func buttonTouchUpInside(_ sender: Any) {
        let someVC = UIViewController()
        someVC.view.backgroundColor = .white
        navigationController?.pushViewController(someVC, animated: true)
    }

    private func changeColor() {
        storyboardProgressBar.primaryColor = UIColor(red: CGFloat.random(in: 0..<255)/255, green: CGFloat.random(in: 0..<255)/255, blue: CGFloat.random(in: 0..<255)/255, alpha: 1)
    }
}
