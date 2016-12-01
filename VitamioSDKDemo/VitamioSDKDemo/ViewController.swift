//
//  ViewController.swift
//  VitamioSDKDemo
//
//  Created by targetcloud on 2016/11/30.
//  Copyright © 2016年 targetcloud. All rights reserved.
//
//可用格式
/*
 ".M1V", ".MP2", ".MPE", ".MPG", ".WMAA",
 ".MPEG", ".MP4", ".M4V", ".3GP", ".3GPP", ".3G2", ".3GPP2", ".MKV",
 ".WEBM", ".MTS", ".TS", ".TP", ".WMV", ".ASF", ".ASX", ".FLV",
 ".MOV", ".QT", ".RM", ".RMVB", ".VOB", ".DAT", ".AVI", ".OGV",
 ".OGG", ".VIV", ".VIVO", ".WTV", ".AVS", ".SWF", ".YUV"
 */
//http://yixia.github.io/Vitamio-iOS/Classes/VMediaPlayer.html#//api/name/getDuration
import UIKit
import AVFoundation

class ViewController: UIViewController,VMediaPlayerDelegate {

    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playOrPauseBtn: UIButton!
    @IBOutlet weak var videoPlayerView: UIView!
    
    lazy var mMPlayer : VMediaPlayer = {
        let player = VMediaPlayer.sharedInstance()
        player?.setupPlayer(withCarrierView: self.videoPlayerView, with: self)
        return player!
    }()
    
    fileprivate var didPrepared : Bool = false
    fileprivate var isShowToolView : Bool?
    fileprivate var progressTimer : Timer?
    
    func prepareVideo(){
        UIApplication.shared.isIdleTimerDisabled = true
        let url = URL(string: "http://v1.mukewang.com/57de8272-38a2-4cae-b734-ac55ab528aa8/L.mp4")
        removeProgressTimer()
        addProgressTimer()
        mMPlayer.setDataSource(url!)
        mMPlayer.prepareAsync()
    }
    
    @IBAction func play() {
        if mMPlayer.isPlaying(){
            mMPlayer.pause()
            removeProgressTimer()
            playOrPauseBtn.isSelected = false
        }else{
            if didPrepared{
                mMPlayer.start()
                addProgressTimer()
            }else{
                prepareVideo()
            }
            playOrPauseBtn.isSelected = true
        }
    }
    
    @IBAction func stop() {
        playOrPauseBtn.isSelected = false
        didPrepared = false
        mMPlayer.reset()
        removeProgressTimer()
    }
    
    @IBAction func valueChange(_ sender: UISlider) {
        let time = Int(sender.value * Float((mMPlayer.getDuration())))
        mMPlayer.seek(to: time)
        let currentTime  = TimeInterval(Float(mMPlayer.getDuration()/1000) * progressSlider.value);
        let duration  = TimeInterval(mMPlayer.getDuration()/1000);
        timeLabel.text = stringWithCurrentTime(currentTime ,duration)
    }
    
    @IBAction func tapAction(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            if self.isShowToolView!{
                self.toolView.alpha = 0
                self.isShowToolView = false
            }else{
                self.toolView.alpha = 1
                self.isShowToolView = true
            }
        })
    }
    
    // delegate 的三个方法
    func mediaPlayer(_ player: VMediaPlayer!, didPrepared arg: Any) {
        playOrPauseBtn.isSelected = true//暂停
        didPrepared = true
        player.start()
        addProgressTimer()
    }
    
    func mediaPlayer(_ player: VMediaPlayer!, playbackComplete arg: Any) {
        playOrPauseBtn.isSelected = false//播放
        didPrepared = false
        player.reset()
        removeProgressTimer()
    }
    
    func mediaPlayer(_ player: VMediaPlayer!, error arg: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressSlider.setThumbImage(UIImage(named: "thumbImage"), for: UIControlState())
        progressSlider.value = 0
        toolView.alpha = 0
        isShowToolView = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPlayerView?.frame = view.bounds
        toolView.frame = CGRect(x: toolView.frame.origin.x, y: videoPlayerView.bounds.size.height-toolView.bounds.size.height, width: toolView.bounds.size.width, height: toolView.bounds.size.height)
    }

    func removeProgressTimer(){
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    func addProgressTimer(){
        progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgressInfo), userInfo: nil, repeats: true)
        RunLoop.main.add(progressTimer!, forMode: RunLoopMode.commonModes)
    }
    
    func updateProgressInfo(){
        timeLabel.text = stringWithCurrentTime(TimeInterval(mMPlayer.getCurrentPosition()/1000),TimeInterval(mMPlayer.getDuration()/1000))
        progressSlider.value = Float(mMPlayer.getCurrentPosition()) / Float(mMPlayer.getDuration())
    }
    
    func stringWithCurrentTime(_ currentTime:TimeInterval,_ duration:TimeInterval)->String{
        let dMin = Int(duration) / 60
        let dSec = Int(duration) % 60
        let durationString = String(format:"%02ld:%02ld",dMin,dSec)
        let cMin = Int(currentTime) / 60
        let cSec = Int(currentTime) % 60
        let currentString = String(format:"%02ld:%02ld",cMin,cSec)
        return currentString + "/" + durationString
    }
}

