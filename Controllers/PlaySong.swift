//
//  PlaySongViewController.swift
//  tableview
//
//  Created by Алексей  Червон  on 08.01.18.
//  Copyright © 2018 eInternetFunAlexChervon. All rights reserved.
//  Менюшка внизу

import UIKit
import UserNotifications

class PlaySong: UIViewController, TimeChanged {

   var delegate: CurrentTrackDelegate?

    
    var SongName = ""
    var Play = false
 
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var NameSong: UILabel!
    @IBOutlet weak var SliderTime: UISlider!
    
    @IBOutlet weak var StartTime: UILabel!
    @IBOutlet weak var EndTIme: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLbl), name:NSNotification.Name(rawValue: "refresh"), object: nil)
        
        
        NameSong.text = SongName
        NameSong.center.x = self.view.frame.width + 60
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
            self.NameSong.center.x = self.view.frame.width / 2
        }), completion: nil)
        
        SliderTime.value = 0
        
        SliderTime.addTarget(self, action: #selector(changeSeekTime), for: UIControlEvents.valueChanged)
        
          }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
   
  
   
    func refreshLbl(_ notification: Notification) {
        let message  = notification.userInfo!["item"] as! String
        NameSong.text = message  
    }
   
    func changeSeekTime() {
        delegate?.changeTime(value: Double(SliderTime.value))
    }

    func animationLabel(x:CGFloat){
        NameSong.center.x = x
        print(self.view.frame.width)
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
            self.NameSong.center.x = self.view.frame.width / 2
        }), completion: nil)
    }
    
    func ImageAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
            self.Image.transform = CGAffineTransform(scaleX: 1.6,y: 1.6)
            

        }), completion: nil)
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: [], animations: ({
            self.Image.transform = CGAffineTransform(scaleX: 1.0,y: 1.0)
            
            
        }), completion: nil)
    }

    @IBAction func Play(_ sender: Any) {
        ImageAnimation()
        delegate?.Play()
    }
    
  
    @IBAction func Prev(_ sender: Any) {
        animationLabel(x:self.view.frame.width - self.view.frame.width+60)
        delegate?.Prev()
        SliderTime.value = 0
        //delegate?.go()
    }
 
    @IBAction func Next(_ sender: Any) {
        animationLabel(x:self.view.frame.width + 60)
        delegate?.Next()
        SliderTime.value = 0
      // delegate?.go()
    }
    func changeTimeSlider(time: Float, start: String, duration: String) {
        print("slider " + String(time))
        SliderTime.value = time
        StartTime.text = start
        EndTIme.text = duration
       
    }
  
}





