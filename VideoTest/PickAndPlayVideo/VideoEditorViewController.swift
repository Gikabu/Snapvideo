import UIKit
import AVFoundation

class VideoEditorViewController: UIViewController {
    let player: AVPlayer
    let playerLayer: AVPlayerLayer
    let playerView = UIView()
    lazy var resumeImageView = UIImageView(image: UIImage(named: "playCircle")?.withRenderingMode(.alwaysTemplate))
    let bgLayer: AVPlayerLayer
    var playerRateObservation: NSKeyValueObservation?
    var effectsButton = UIButton()
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
        self.playerLayer = AVPlayerLayer(player: player)
        self.bgLayer = AVPlayerLayer(player: player)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        setUpBackgroundView()
        setUpPlayerView()
        setUpPlayer()
        setUpEffectButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerView.frame
        bgLayer.frame = view.frame
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if player.rate == 0 {
            player.play()
        } else {
            player.pause()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUpPlayer() {
        //1 Подписка на событие достижения конца видео
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd(notification:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        //2 Подписка на изменение рейта плейера - (играю/не играю)
        playerRateObservation = player.observe(\.rate) { [weak self] (_, _) in
            guard let self = self else { return }
            self.resumeImageView.isHidden = self.player.rate > 0
        }
    }
    
    func setUpPlayerView() {
        playerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(playerView)
        NSLayoutConstraint.activate ([
        playerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        playerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        playerView.topAnchor.constraint(equalTo: self.view.topAnchor),
        playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)])
        playerView.layer.addSublayer(playerLayer)
        resumeImageView.translatesAutoresizingMaskIntoConstraints = false
        playerView.addSubview(resumeImageView)
        NSLayoutConstraint.activate([
        resumeImageView.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
        resumeImageView.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
        resumeImageView.heightAnchor.constraint(equalToConstant: 70),
        resumeImageView.widthAnchor.constraint(equalToConstant: 70)
        ])
        resumeImageView.tintColor = .white
        resumeImageView.isUserInteractionEnabled = false
        resumeImageView.isHidden = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        playerView.addGestureRecognizer(tap)
    }
    
    func setUpBackgroundView() {
        self.view.layer.addSublayer(bgLayer)
        bgLayer.videoGravity = .resizeAspectFill
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        self.view.addSubview(visualEffectView)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor),
            view.rightAnchor.constraint(equalTo: visualEffectView.rightAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor)])
    }
    
    func setUpEffectButton() {
        effectsButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(effectsButton)
        NSLayoutConstraint.activate ([
            effectsButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        effectsButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        effectsButton.heightAnchor.constraint(equalToConstant: 44),
        effectsButton.widthAnchor.constraint(equalToConstant: 44)
        ])
        effectsButton.setImage(UIImage(named: "effects")?.withRenderingMode(.alwaysTemplate), for: .normal)
        effectsButton.tintColor = .white
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }
}
