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

    /*
     By default if the determine state is set before the view is rendered the progress will begin at that value
     If `animateDeterminateInitialization` is True then the progress bar will start at zero and animate to the value.
     */
    @IBInspectable
    open var animateDeterminateInitialization: Bool = false

    open var indeterminateAnimationDuration: TimeInterval = 1.0
    open var determinateAnimationDuration: TimeInterval = 1.0

    private var zeroFrame: CGRect {
        CGRect(origin: .zero, size: CGSize(width: 0, height: bounds.size.height))
    }
    
    //MARK: Lifecycle

    override public init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        updateForForegroundState()
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        if window == nil {
            updateForBackgroundState()
        } else {
            updateForForegroundState()
        }
    }

    @objc func willMoveToBackground() {
        updateForBackgroundState()
    }

    @objc func willEnterForeground() {
        updateForForegroundState()
    }

    //MARK: Setup

    private func commonInit() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willMoveToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

        setupViews()
    }

    private func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        self.backgroundColor = secondaryColor
        
        progressBarIndicator = UIView(frame: zeroFrame)
        progressBarIndicator.backgroundColor = primaryColor
        progressBarIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(progressBarIndicator)
    }
    
    //MARK: Public API

    public func transition(to state: NicoProgressBarState,
                           delay: TimeInterval = 0,
                           animateDeterminate: Bool = true,
                           completion: ((Bool) -> Void)? = nil) {

        guard window != nil else {
            self.state = state
            return
        }

        switch state {
            case .determinate(let percentage):
                stopIndeterminateAnimation()
                animateProgress(toPercent: percentage, delay: delay, animated: animateDeterminate, completion: completion)
            case .indeterminate:
                startIndeterminateAnimation(delay: delay)
                completion?(true)
        }
        
        self.state = state
    }
    
    // MARK: Private
    private func updateForBackgroundState() {
        stopIndeterminateAnimation()
    }

    private func updateForForegroundState() {
        DispatchQueue.main.async {
            self.transition(to: self.state, animateDeterminate: self.animateDeterminateInitialization)
        }
    }

    private func animateProgress(toPercent percent: CGFloat,
                                 delay: TimeInterval = 0,
                                 animated: Bool = true,
                                 completion: ((Bool) -> Void)? = nil) {
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
    
    private func stopIndeterminateAnimation() {
        switch state {
            case .indeterminate: moveProgressBarIndicatorToStart()
            case .determinate: break
        }
    }
    
    private func moveProgressBarIndicatorToStart() {
        progressBarIndicator.layer.removeAllAnimations()
        progressBarIndicator.frame = zeroFrame
        progressBarIndicator.layoutIfNeeded()
    }
    
    private func startIndeterminateAnimation(delay: TimeInterval = 0) {
        moveProgressBarIndicatorToStart()

        UIView.animateKeyframes(
            withDuration: indeterminateAnimationDuration,
            delay: delay,
            options: [.repeat],
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
        })
    }
}
