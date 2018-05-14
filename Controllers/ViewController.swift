//
//  ViewController.swift
//  tableview
//
//  Created by Алексей  Червон  on 25.12.17.
//  Copyright © 2017 eInternetFunAlexChervon. All rights reserved.
//  Для получения офф токена, писать на chervon@cit-psu.ru

import UIKit
import AVFoundation

class ViewController: UITableViewController {
    
    @IBOutlet var MyTable: UITableView!


    let token = "ce1ef44762051787674fa133ec9b2144b47281a7deddaa487f7a39123136593706d6522d976d6844fd3cd"
    var avPlayer:AVPlayer?
    var avPlayerItem:AVPlayerItem?
    
    var dataMas = [String]()
    var musicLink = [String]()
    var titleTrack = [String]()
    
    var CurrentMusic = [Int]()
    
    var PlayNow = ["track":"","url":"","thisTime":"","aid":""]
    var SeekTime = Float()
    
    var selectedRowNumber: Int? = nil
    
    var AllButtons = [UIButton]()
    let playbackSlider = UISlider(frame:CGRect(x:90, y:60, width:250, height:20))
    
    
    var Duration = CMTime()
    
   
    

    
    enum SongState {
        
        case playing, stopped, undefined //etc
    }
    
    struct Song {
        var name = ""
        var artist = ""
        var audioFile = ""
        var state: SongState = .undefined
    }
    
var playList = [Song]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GetMusicTrack()
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Загрузка треков")
        refreshControl!.addTarget(self, action: #selector(ViewController.loadData(_:)), for: UIControlEvents.valueChanged)
        let backgroundImage = UIImage(named: "bgall.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        playbackSlider.isHidden = true
           }
    
    

    func GetMusicTrack() {
        avPlayer?.pause()
        self.playList.removeAll()
        
        let url = URL(string: "https://api.vk.com/method/audio.get?uid=97257820&count=100&access_token=\(token)")
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                if let responseJson = json["response"] as? [[String:AnyObject]] {
                    for responseWow in responseJson {
                        if let artist = responseWow["artist"] as? String, let title = responseWow["title"] as? String, let url = responseWow["url"] as? String {
                           //self.dataMas.append(String(artist))
                           // self.titleTrack.append(String(title))
                            //self.musicLink.append(String(url))
                            let Struct = Song(name: String(title), artist: String(artist), audioFile: String(url), state: ViewController.SongState.undefined)
                            self.playList.append(Struct)
                            
                            if (self.playList.count > 1) {
                                self.tableView.reloadData()
                            }
                        }
                        print(self.dataMas)
                        
                    }
                }
          
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                           }
            
        }) 
        
        
        task.resume()
       
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                UIApplication.shared.beginReceivingRemoteControlEvents()
                print("AVAudioSession is Active")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playList.count
        
    }
    
   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.separatorStyle = .none
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UIT
         var imageView  = UIImageView(frame:CGRect(x: 0, y: 0, width: 100, height: 200))
        let image = UIImage(named: "trackBG.png")
        
        imageView = UIImageView(image:image)
        
        //cell.backgroundView = imageView
        //cell.backgroundView?.frame = cell.frame.offsetBy(dx: 10, dy: 10);
        
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
       
        //self.view.addSubview(playbackSlider)
        
        
        cell.btns.addTarget(self, action: #selector(self.PlayTrack(_:)), for: UIControlEvents.touchUpInside )
        
        if (self.playList.count > 1) {
            
            cell.TitleLabel.text=playList[indexPath.row].name
            cell.name.text = playList[indexPath.row].artist
            
            cell.btns.tag = indexPath.row
            self.selectedRowNumber = cell.btns.tag
     
            
        } else {
            print("array of index")
        }
        
        if (self.playList.count > 1) {
            switch playList[indexPath.row].state {
            case .undefined:
                cell.btns.setBackgroundImage(UIImage(named: "play.png"), for: .normal)
                
                playbackSlider.isHidden = true

                print("undefined")

            case .playing:
                cell.btns.setBackgroundImage(UIImage(named: "stop-paly.png"), for: .normal)
                playbackSlider.isHidden = false
                print("playing")
            default:
                cell.btns.setBackgroundImage(UIImage(named: "play.png"), for: .normal)
               // playbackSlider.isHidden = true
                print("default")
                break
            }
 
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        }
   
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "I'm a test label"
        label.tag = section
        
       // let tap = UITapGestureRecognizer(target: self, action: #selector(SomeViewController.tapFunction))
        label.isUserInteractionEnabled = true
       // label.addGestureRecognizer(tap)
        print("ADDDDDD")
        return label
    }
    
    func PlayTrack (_ sender:UIButton) {
        self.Duration = CMTime()
        

        
       
        self.AllButtons.append(sender)
        guard let cell = sender.findClass(type: UIT.self) else {return}
        guard let indexPath = self.tableView.indexPath(for: cell) else { return }
        cell.insertSubview(playbackSlider, at: 1)
        
        //playbackSlider.addTarget(self, action: Selector(("playbackSliderValueChanged:")), for: .valueChanged)
        playbackSlider.addTarget(self, action: #selector(self.playbackSliderValueChanged(playbackSlider:)), for: UIControlEvents.touchUpInside )
        if playList[indexPath.row].state == .undefined {
            playList[indexPath.row].state = .playing
            
            for  i in 0...playList.count-1 {
                if (i != indexPath.row) {
                    playList[i].state = .undefined
                }
                
            }
          
            sender.setBackgroundImage(UIImage(named: "stop-paly.png"), for: UIControlState.normal)
                       PlayNextTrack(number: sender.tag)

        } else if (playList[indexPath.row].state == .playing) {
            playList[indexPath.row].state = .undefined
            avPlayer?.pause()
            print("STOP")
            
            let duration : CMTime = avPlayerItem!.currentTime()
            let seconds : Float64 = CMTimeGetSeconds(duration)
            
            self.PlayNow.updateValue(playList[indexPath.row].name, forKey: "track")
            self.PlayNow.updateValue(playList[indexPath.row].audioFile, forKey: "url")
            self.PlayNow.updateValue(String(sender.tag), forKey: "aid")
            SeekTime = Float(seconds)
            print(PlayNow)
        }

    self.tableView.reloadData()
                   }
    
    
  
    func PlayNextTrack(number:Int) {
        
        
      
        if (String(number) != PlayNow["aid"]) {
            SeekTime = 0.0
            playbackSlider.value = 0

        }
       
        
        self.CurrentMusic.append(number)
        
        if (number >= self.playList.count) {
            print(String(number) + " " + String(self.CurrentMusic.count))
            self.CurrentMusic.removeAll()
            self.CurrentMusic.append(0)
            
        }
       
        let url = URL(string: playList[CurrentMusic[self.CurrentMusic.endIndex-1]].audioFile)
        avPlayerItem = AVPlayerItem.init(url: url! as URL)
        avPlayer = AVPlayer.init(playerItem: avPlayerItem!)
        avPlayer?.volume = 1.0
        avPlayer?.automaticallyWaitsToMinimizeStalling = false

        let seconds : Int64 = Int64(SeekTime)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        avPlayer?.currentItem?.seek(to: targetTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        self.Duration = avPlayerItem!.asset.duration
        let secondsAll : Float64 = CMTimeGetSeconds(self.Duration)
        playbackSlider.maximumValue = Float(Float(secondsAll))
        playbackSlider.isContinuous=true
        avPlayer?.play()
        
     
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.FinishTrack(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
    }
    
    func playbackSliderValueChanged(playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
       avPlayer?.currentItem?.seek(to: targetTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
        
        if avPlayer!.rate == 0
        {
            avPlayer?.play()
        }
    }
    
    func loadData(_ _refreshControl: UIControlEvents) {
        
         GetMusicTrack()
        
        refreshControl!.endRefreshing()
    }
   
    func FinishTrack (_ note: NSNotification) {
        PlayNextTrack(number: self.CurrentMusic[self.CurrentMusic.endIndex-1]+1)
        
    }
    
    func resetAll() {
        self.tableView.reloadData()
    }
    

}
//extension UIView {
//    func findClass<T>(type: T.Type) -> T? {
//        var parentResponder: UIResponder? = self
//        while parentResponder != nil {
//            parentResponder = parentResponder!.next
//            if let view = parentResponder as? T {
//                return view
//            }
//        }
//        return nil
//    }
//}

