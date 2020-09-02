import UIKit

//MARK: - NicoProgressBarState
public enum NicoProgressBarState: Equatable {
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
    open private(set) var state: NicoProgressBarState = .indeterminate
    
    //MARK: Public Properties
    @IBInspectable
    open var primaryColor: UIColor = .blue {
        didSet {
            progressBarIndicator.backgroundColor = primaryColor
            self.layoutIfNeeded()
        }
    }
    @IBInspectable
    open var secondaryColor: UIColor = .lightGray {
        didSet {
            self.backgroundColor = secondaryColor
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

        moveProgressBarIndicatorToStart()
        DispatchQueue.main.async {
            self.transition(to: self.state)
        }
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == nil {
            stopIndeterminateAnimation()
        }
    }

    //MARK: Setup
    private func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.backgroundColor = secondaryColor
        
        progressBarIndicator = UIView(frame: zeroFrame)
        progressBarIndicator.backgroundColor = primaryColor
        progressBarIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(progressBarIndicator)
        
        moveProgressBarIndicatorToStart()
    }
    
    //MARK: Public API
    public func transition(to newState: NicoProgressBarState, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        guard self.state != newState else {
            completion?(false)
            return
        }

        switch self.state {
            case .indeterminate:
                moveProgressBarIndicatorToStart()
            case .determinate(_):
                break
        }
        
        switch newState {
            case .determinate(let percentage):
                stopIndeterminateAnimation()
                animateProgress(toPercent: percentage, delay: delay, completion: completion)
            case .indeterminate:
                startIndeterminateAnimation(delay: delay)
                completion?(true)
        }
        
        self.state = newState
    }
    
    // MARK: Private
    private func animateProgress(toPercent percent: CGFloat, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: determinateAnimationDuration, delay: delay, options: [.beginFromCurrentState], animations: {
            self.progressBarIndicator.frame = CGRect(x: 0, y: 0, width: self.bounds.width * percent, height: self.bounds.size.height)
        }, completion: completion)
    }
    
    private func startIndeterminateAnimation(delay: TimeInterval = 0) {
        if !isIndeterminateAnimationRunning {
            isIndeterminateAnimationRunning = true
            runIndeterminateAnimationLoop(delay: delay)
        }
    }
    
    private func stopIndeterminateAnimation() {
        isIndeterminateAnimationRunning = false
    }
    
    private func moveProgressBarIndicatorToStart() {
        progressBarIndicator.layer.removeAllAnimations()
        progressBarIndicator.frame = zeroFrame
        progressBarIndicator.layoutIfNeeded()
    }
    
    private var zeroFrame: CGRect {
        return CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: bounds.size.height))
    }
    
    private func runIndeterminateAnimationLoop(delay: TimeInterval = 0) {
        moveProgressBarIndicatorToStart()
        
        UIView.animateKeyframes(withDuration: indeterminateAnimationDuration, delay: delay, options: [], animations: { [weak self] in
            guard let strongSelf = self else { return }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: strongSelf.indeterminateAnimationDuration/2, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.progressBarIndicator.frame = CGRect(x: 0, y: 0, width: strongSelf.bounds.width * 0.7, height: strongSelf.bounds.size.height)
            })
            UIView.addKeyframe(withRelativeStartTime: strongSelf.indeterminateAnimationDuration/2, relativeDuration: strongSelf.indeterminateAnimationDuration/2, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.progressBarIndicator.frame = CGRect(x: strongSelf.bounds.width, y: 0, width: strongSelf.bounds.width * 0.3, height: strongSelf.bounds.size.height)
            })
        }) { [weak self] _ in
            guard let strongSelf = self else { return }

            if strongSelf.isIndeterminateAnimationRunning {
                strongSelf.runIndeterminateAnimationLoop()
            }
        }
    }
}
