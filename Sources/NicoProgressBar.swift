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
    open private(set) var state: NicoProgressBarState = .indeterminate

    //MARK: Public Properties
    @IBInspectable
    open var primaryColor: UIColor = .blue {
        didSet {
            progressBarIndicator.backgroundColor = primaryColor
        }
    }
    @IBInspectable
    open var secondaryColor: UIColor = .lightGray {
        didSet {
            self.backgroundColor = secondaryColor
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

        DispatchQueue.main.async {
            self.moveProgressBarIndicatorToStart()
            self.transition(to: self.state, animateDeterminate: false)
        }
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        switch state {
            case .indeterminate:
                // Only run the indeterminate animation if visible on screen
                if window == nil {
                    stopIndeterminateAnimation()
                } else {
                    startIndeterminateAnimation()
                }
            case .determinate:
                break
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
    public func transition(to newState: NicoProgressBarState, delay: TimeInterval = 0, animateDeterminate: Bool = true, completion: ((Bool) -> Void)? = nil) {
        switch self.state {
            case .indeterminate:
                moveProgressBarIndicatorToStart()
            case .determinate(_):
                break
        }
        
        switch newState {
            case .determinate(let percentage):
                stopIndeterminateAnimation()
                animateProgress(toPercent: percentage, delay: delay, animated: animateDeterminate, completion: completion)
            case .indeterminate:
                startIndeterminateAnimation(delay: delay)
                completion?(true)
        }
        
        self.state = newState
    }
    
    // MARK: Private
    private func animateProgress(toPercent percent: CGFloat, delay: TimeInterval = 0, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(
            withDuration: animated ? determinateAnimationDuration : 0,
            delay: delay,
            options: [.beginFromCurrentState],
            animations: {
                self.progressBarIndicator.frame = CGRect(x: 0, y: 0,
                                                         width: self.bounds.width * percent,
                                                         height: self.bounds.size.height)
            },
            completion: completion)
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
        return CGRect(origin: .zero, size: CGSize(width: 0, height: bounds.size.height))
    }
    
    private func runIndeterminateAnimationLoop(delay: TimeInterval = 0) {
        moveProgressBarIndicatorToStart()

        UIView.animateKeyframes(
            withDuration: indeterminateAnimationDuration,
            delay: delay,
            options: [],
            animations: { [weak self] in
                guard let self = self else { return }

                UIView.addKeyframe(
                    withRelativeStartTime: 0,
                    relativeDuration: self.indeterminateAnimationDuration/2,
                    animations: { [weak self] in
                        guard let self = self else { return }

                        self.progressBarIndicator.frame = CGRect(x: 0, y: 0,
                                                                 width: self.bounds.width * 0.7,
                                                                 height: self.bounds.size.height)
                    })

                UIView.addKeyframe(
                    withRelativeStartTime: self.indeterminateAnimationDuration/2,
                    relativeDuration: self.indeterminateAnimationDuration/2,
                    animations: { [weak self] in
                        guard let self = self else { return }

                        self.progressBarIndicator.frame = CGRect(x: self.bounds.width, y: 0,
                                                                 width: self.bounds.width * 0.3,
                                                                 height: self.bounds.size.height)
                    })
        }) { [weak self] _ in
            guard let self = self else { return }

            if self.isIndeterminateAnimationRunning {
                self.runIndeterminateAnimationLoop()
            }
        }
    }
}
