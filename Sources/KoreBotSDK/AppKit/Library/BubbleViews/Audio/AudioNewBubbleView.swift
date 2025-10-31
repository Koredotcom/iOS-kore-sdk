//
//  AudioNewBubbleView.swift
//  KoreBotSDK
//
//  Created by Pagidimarri Kartheek on 22/10/25.
//

import UIKit
import AVFoundation
#if SWIFT_PACKAGE
import ObjcSupport
#endif

class AudioNewBubbleView: BubbleView {
    let bundle = Bundle.sdkModule
    var cardView: UIView!
    let kMaxTextWidth: CGFloat = BubbleViewMaxWidth - 80.0
    var audioView: UIView!
    var titleLbl: KREAttributedLabel!
    private var audioTopToTitleConstraint: NSLayoutConstraint!
    private var audioTopToCardConstraint: NSLayoutConstraint!

    // MARK: Audio UI Elements
    private var playPauseButton: UIButton!
    private var slider: UISlider!
    private var startTimeLabel: UILabel!
    private var endTimeLabel: UILabel!
    private var downloadButton: UIButton!

    // MARK: Audio Player
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    private var isPlaying = false
    private var isSliderBeingDragged = false

    let dropDown = DropDown()
    lazy var dropDowns: [DropDown] = { [self.dropDown] }()

    // MARK: Lifecycle
    override func applyBubbleMask() {}
    override var tailPosition: BubbleMaskTailPosition! {
        didSet { self.backgroundColor = .clear }
    }

    override func initialize() {
        super.initialize()
        initializeCardLayout()
        setupTitleLabel()
        setupAudioView()
        setupAudioControls()
        layoutConstraints()
    }

    private func initializeCardLayout() {
        cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cardView)
        cardView.layer.cornerRadius = 10
        cardView.backgroundColor = BubbleViewLeftTint

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupTitleLabel() {
        titleLbl = KREAttributedLabel()
        titleLbl.textColor = BubbleViewBotChatTextColor
        titleLbl.font = UIFont(name: mediumCustomFont, size: 16)
        titleLbl.numberOfLines = 0
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLbl)
    }

    private func setupAudioView() {
        audioView = UIView()
        audioView.translatesAutoresizingMaskIntoConstraints = false
        audioView.backgroundColor = .white
        audioView.layer.cornerRadius = 14
        audioView.layer.borderWidth = 0.5
        if #available(iOS 13.0, *) {
            audioView.layer.borderColor = UIColor.clear.cgColor
        }
        cardView.addSubview(audioView)
    }

    private func setupAudioControls() {
        // Play / Pause Button
        playPauseButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        playPauseButton.tintColor = .black
        playPauseButton.backgroundColor = .clear
        playPauseButton.layer.cornerRadius = 22
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        audioView.addSubview(playPauseButton)

        // Slider
        slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.minimumTrackTintColor = BubbleViewRightTint
        if #available(iOS 13.0, *) {
            slider.maximumTrackTintColor = UIColor.systemGray5
        }
        if #available(iOS 13.0, *) {
            slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        }
        slider.tintColor = .black
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchDown(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside])
        audioView.addSubview(slider)

        // Time labels
        startTimeLabel = UILabel()
        startTimeLabel.text = "0:00"
        startTimeLabel.font = UIFont.systemFont(ofSize: 12)
        startTimeLabel.textColor = .darkGray
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        audioView.addSubview(startTimeLabel)

        endTimeLabel = UILabel()
        endTimeLabel.text = "--:--"
        endTimeLabel.font = UIFont.systemFont(ofSize: 12)
        endTimeLabel.textColor = .darkGray
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        audioView.addSubview(endTimeLabel)

        // Download / More Button
        downloadButton = UIButton(type: .system)
        if let imgV = UIImage(named: "moreB", in: bundle, compatibleWith: nil) {
            downloadButton.setImage(imgV.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        downloadButton.tintColor = .darkGray
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.addTarget(self, action: #selector(downloadButtonAction), for: .touchUpInside)
        audioView.addSubview(downloadButton)
    }

    private func layoutConstraints() {
        audioTopToTitleConstraint = audioView.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 10)
        audioTopToCardConstraint = audioView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10)
        audioTopToTitleConstraint.isActive = true
        audioTopToCardConstraint.isActive = false

        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            titleLbl.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLbl.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            audioView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            audioView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            audioView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            audioView.heightAnchor.constraint(equalToConstant: 80),

            playPauseButton.leadingAnchor.constraint(equalTo: audioView.leadingAnchor, constant: 12),
            playPauseButton.centerYAnchor.constraint(equalTo: audioView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 32),
            playPauseButton.heightAnchor.constraint(equalToConstant: 32),

            downloadButton.trailingAnchor.constraint(equalTo: audioView.trailingAnchor, constant: -10),
            downloadButton.centerYAnchor.constraint(equalTo: audioView.centerYAnchor),
            downloadButton.widthAnchor.constraint(equalToConstant: 32),
            downloadButton.heightAnchor.constraint(equalToConstant: 32),

            slider.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 10),
            slider.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -10),
            slider.centerYAnchor.constraint(equalTo: audioView.centerYAnchor),

            startTimeLabel.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            startTimeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 4),

            endTimeLabel.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
            endTimeLabel.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 4)
        ])
    }

    // MARK: - Populate
    override func populateComponents() {
        guard components.count > 0 else { return }
        let component = components.firstObject as! KREComponent
        var titleStr = ""
        if let jsonString = component.componentDesc {
            let jsonObject = Utilities.jsonObjectFromString(jsonString: jsonString) as! NSDictionary
            titleStr = jsonObject["text"] as? String ?? ""
            titleLbl.setHTMLString(titleStr, withWidth: kMaxTextWidth)

            if let audioUrlString = jsonObject["audioUrl"] as? String,
               let url = URL(string: audioUrlString) {
                setupAudioPlayer(with: url)
            }
        }
        // Hide title label if empty and adjust audioView top
        let trimmedTitle = titleStr.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            titleLbl.isHidden = true
            audioTopToTitleConstraint.isActive = false
            audioTopToCardConstraint.isActive = true
        } else {
            titleLbl.isHidden = false
            audioTopToCardConstraint.isActive = false
            audioTopToTitleConstraint.isActive = true
        }
        setNeedsLayout()
        layoutIfNeeded()
        ConfigureDropDownView()
    }

    // MARK: - Player Setup
    private func setupAudioPlayer(with url: URL) {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        playerItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)

        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.5, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self,
                  let duration = self.playerItem?.duration.seconds,
                  duration.isFinite, duration > 0 else { return }

            let current = time.seconds
            if !self.isSliderBeingDragged {
                self.slider.value = Float(current / duration)
            }
            self.startTimeLabel.text = self.formatTime(current)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let item = object as? AVPlayerItem, item.status == .readyToPlay {
            let duration = item.duration.seconds
            if duration.isFinite { endTimeLabel.text = formatTime(duration) }
        }
    }

    // MARK: - Player Control
    @objc private func togglePlayPause() {
        guard let player = player else { return }
        if isPlaying {
            player.pause()
            if #available(iOS 13.0, *) {
                playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        } else {
            player.play()
            if #available(iOS 13.0, *) {
                playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            }
        }
        isPlaying.toggle()
    }

    @objc private func playerDidFinishPlaying() {
        isPlaying = false
        slider.value = 0
        startTimeLabel.text = "0:00"
        if #available(iOS 13.0, *) {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        player?.seek(to: .zero)
    }

    // MARK: - Slider Interaction
    @objc private func sliderTouchDown(_ sender: UISlider) {
        isSliderBeingDragged = true
    }

    @objc private func sliderTouchUp(_ sender: UISlider) {
        guard let duration = playerItem?.duration.seconds, duration.isFinite else { return }
        let newTime = Double(sender.value) * duration
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
        isSliderBeingDragged = false
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        guard let duration = playerItem?.duration.seconds, duration.isFinite else { return }
        let newTime = Double(sender.value) * duration
        startTimeLabel.text = formatTime(newTime)
    }

    // MARK: Helpers
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "--:--" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    deinit {
        if let token = timeObserverToken { player?.removeTimeObserver(token) }
    }
    
    // MARK: Download File
   @objc private func downloadButtonAction() {
        dropDown.show()
    }
}
extension AudioNewBubbleView {
    func ConfigureDropDownView(){
        //DropDown
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }

        dropDown.backgroundColor = UIColor(white: 1, alpha: 1)
        dropDown.selectionBackgroundColor = BubbleViewLeftTint
        dropDown.separatorColor = .white//UIColor(white: 0.7, alpha: 0.8)
        dropDown.cornerRadius = 10
        dropDown.shadowColor = UIColor(white: 0.6, alpha: 1)
        dropDown.shadowOpacity = 0.9
        dropDown.shadowRadius = 25
        dropDown.animationduration = 0.25
        dropDown.textColor = BubbleViewBotChatTextColor
        setupColorDropDown()
    }
    // MARK: Setup DropDown
    func setupColorDropDown() {
        dropDown.anchorView = downloadButton
        dropDown.bottomOffset = CGPoint(x: -40, y: -50)
        dropDown.width = 110
        dropDown.dataSource = ["Download"]
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.downloadFile()
        }

    }

    func downloadFile(){
        toastMessageStr = fileDownloadingToastMsg
        NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
        guard let playerItem = playerItem,
              let asset = playerItem.asset as? AVURLAsset else {
            return
        }
        let url = asset.url

        let downloadTask = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                print("Download failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    toastMessageStr = vileDownloadFailedToastMsg
                    NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
                }
                return
            }

            guard let localURL = localURL else {
                print("Download failed: no file URL")
                DispatchQueue.main.async {
                    toastMessageStr = vileDownloadFailedToastMsg
                    NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
                }
                return
            }

            do {
                let fileManager = FileManager.default
                // Get Documents directory
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)

                // Remove existing file if any
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }

                // Move downloaded file to Documents
                try fileManager.moveItem(at: localURL, to: destinationURL)

                DispatchQueue.main.async {
                    print("File downloaded to: \(destinationURL.path)")
                    toastMessageStr = fileSavedSuccessfullyToastMsg
                    NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
                }
            } catch {
                print("File save error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    toastMessageStr = vileDownloadFailedToastMsg
                    NotificationCenter.default.post(name: Notification.Name(pdfcTemplateViewNotification), object: "Show")
                }
            }
        }

        downloadTask.resume()
    }
}
