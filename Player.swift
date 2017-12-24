//
//  Player.swift
//  MusicStar
//
//  Created by Алексей  Червон  on 21.12.17.
//  Copyright © 2017 eInternetFunAlexChervon. All rights reserved.
//

import UIKit
import AVFoundation

class Player: UIViewController {

    @IBOutlet weak var slider: UISlider!
var timer = NSTimer()
    var avPlayer:AVPlayer?
    var avPlayerItem:AVPlayerItem?
    let playbackSlider = UISlider(frame:CGRect(x:10, y:300, width:300, height:20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        print("1")
    
    }
    override func viewWillAppear(animated: Bool) {
         super.viewWillAppear(animated)
        
        let urlstring = "https://cs1-70v4.vk-cdn.net/p1/be38acd7c90ffa.mp3?extra=qbz8CTfHE3LwUfc35L8gWdZ2w92OjYoigxNP3Dcdxrktg_YxGIlceoLjYwPutqHPH3zQyQp8DsNfpO33sgjB2Q8VE9L0uFhAOReogrbXMP-GgIBKYEpq3WFjD7NqnosYGAHrGjLhj074"
        let url = NSURL(string: urlstring)
        print("playing \(String(url))")
        
        avPlayerItem = AVPlayerItem.init(URL: url! as NSURL)
        avPlayer = AVPlayer.init(playerItem: avPlayerItem!)
        avPlayer?.volume = 1.0

        
        
        playbackSlider.minimumValue=0;
        let duration : CMTime = avPlayerItem!.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        playbackSlider.maximumValue = Float(seconds)
        playbackSlider.continuous=true

      playbackSlider.addTarget(self, action: "playbackSliderValueChanged:", forControlEvents: .ValueChanged)
        
        scheduledTimerWithTimeInterval()
        
        
               self.view.addSubview(playbackSlider)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func Play(sender: AnyObject) {
     
        avPlayer?.play()

        
    }
    
    @IBAction func stop(sender: AnyObject) {
        stop()
    }
    

    
    func stop() {
         avPlayer?.pause()
        print("STOP")
    }
    
    func playbackSliderValueChanged(playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        avPlayer!.seekToTime(targetTime)
        
        print(targetTime)
        if avPlayer!.rate == 0
        {
            avPlayer?.play()
        }
    }
    func scheduledTimerWithTimeInterval(){
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateCounting"), userInfo: nil, repeats: true)
    }
    func updateCounting(){
        
        let duration : CMTime = avPlayerItem!.currentTime()
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        print(seconds)
        playbackSlider.value=Float(seconds)
       
        
    }
    
    
}
