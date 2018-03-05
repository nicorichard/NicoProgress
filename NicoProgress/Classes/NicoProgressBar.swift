import UIKit

//MARK: - NicoProgressBarState
public enum NicoProgressBarState {
    case indeterminate
    case determinate(percentage: CGFloat)
    
    public var isDeterminate: Bool {
        switch self {
            case .indeterminate:
                return false
            case .determinate(_):
                return true
        }
    }
}

//MARK: - NicoProgressBar
open class NicoProgressBar: UIView {
    
    //MARK: Private Properties
    
    private var isIndeterminateAnimationRunning = false
    private var progressBarIndicator: UIView!
    private var state: NicoProgressBarState = .determinate(percentage: 0)
    
    //MARK: Public Properties
    
    open var secondaryColor: UIColor = .lightGray {
        didSet {
            self.backgroundColor = secondaryColor
            self.layoutIfNeeded()
        }
    }
    open var primaryColor: UIColor = .blue {
        didSet {
            progressBarIndicator.backgroundColor = primaryColor
            self.layoutIfNeeded()
        }
    }
    open var indeterminateAnimationDuration: TimeInterval = 1.0
    open var determinateAnimationDuration: TimeInterval = 1.0
    
    //MARK: UIView
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupViews()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        switch state {
            case .determinate(let percentage):
                stopIndeterminateAnimation()
                animateProgress(toPercent: percentage)
            case .indeterminate:
                startIndeterminateAnimation()
        }
    }
    
    //MARK: Setup
    
    private func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.backgroundColor = secondaryColor
        
        progressBarIndicator = UIView(frame: zeroFrame)
        progressBarIndicator.backgroundColor = primaryColor
        self.addSubview(progressBarIndicator)
        
        moveProgressBarIndicatorToStart()
    }
    
    //MARK: Public API
    
    public func transition(to state: NicoProgressBarState, completion: ((Bool) -> Void)? = nil) {
        self.state = state
        
        switch state {
            case .determinate(let percentage):
                stopIndeterminateAnimation()
                animateProgress(toPercent: percentage, completion: completion)
            case .indeterminate:
                startIndeterminateAnimation()
                completion?(true)
        }
    }
    
    // MARK: Private Transitions
    
    private func animateProgress(toPercent percent: CGFloat, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: determinateAnimationDuration, delay: 0, options: [], animations: {
            self.progressBarIndicator.frame = CGRect(x: 0, y: 0, width: self.bounds.width * percent, height: self.bounds.size.height)
        }, completion: completion)
    }
    
    private func startIndeterminateAnimation() {
        if !isIndeterminateAnimationRunning {
            isIndeterminateAnimationRunning = true
            runAnimationLoop()
        }
    }
    
    private func stopIndeterminateAnimation() {
        if isIndeterminateAnimationRunning {
            isIndeterminateAnimationRunning = false
            moveProgressBarIndicatorToStart()
        }
    }
    
    private func moveProgressBarIndicatorToStart() {
        self.progressBarIndicator.frame = self.zeroFrame
        self.progressBarIndicator.layoutIfNeeded()
    }
    
    private var zeroFrame: CGRect {
        return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: self.bounds.size.height))
    }
    
    private func runAnimationLoop() {
        guard let superview = self.superview else {
            stopIndeterminateAnimation()
            return
        }
        
        moveProgressBarIndicatorToStart()
        
        UIView.animateKeyframes(withDuration: indeterminateAnimationDuration, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: self.indeterminateAnimationDuration/2, animations: {
                self.progressBarIndicator.frame = CGRect(x: 0, y: 0, width: self.bounds.width * 0.7, height: self.bounds.size.height)
            })
            UIView.addKeyframe(withRelativeStartTime: self.indeterminateAnimationDuration/2, relativeDuration: self.indeterminateAnimationDuration/2, animations: {
                self.progressBarIndicator.frame = CGRect(x: superview.bounds.width, y: 0, width: self.bounds.width * 0.3, height: self.bounds.size.height)
                
            })
        }) { [weak self] _ in
            guard let strongSelf = self else { return }
            
            if strongSelf.isIndeterminateAnimationRunning {
                strongSelf.runAnimationLoop()
            }
        }
    }
}
