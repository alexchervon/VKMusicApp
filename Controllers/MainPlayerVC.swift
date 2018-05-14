//
//  MainPlayerVC.swift
//  tableview
//
//  Created by Алексей  Червон  on 02.01.18.
//  Copyright © 2018 eInternetFunAlexChervon. All rights reserved.
//  Основной контроллер 


import UIKit
import AVFoundation
import Foundation
import MediaPlayer

protocol TimeChanged: NSObjectProtocol {
    func changeTimeSlider(time: Float, start: String, duration: String)
}

class MainPlayerVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CurrentTrackDelegate{
    
//Second ViewController
    @IBOutlet weak var CurrentNameSong: UILabel!
    @IBOutlet weak var CurrentArtistName: UILabel!

    
@IBOutlet weak var TableSong: UITableView!
    
@IBOutlet weak var ViewCurrentSong: UIView!
    
// State for button
enum SongState {
        
        case playing, stopped, undefined
    }

//In this struct save audio track
struct Song {
        var name = ""
        var artist = ""
        var audioFile = ""
        var state: SongState = .undefined
    }
    
// This all song
    var playList = [Song]()
    
//Create avPlayer Object
    var avPlayer:AVPlayer?
    var avPlayerItem:AVPlayerItem?

// current song view
    @IBOutlet weak var cs_name: UILabel!
    @IBOutlet weak var cs_artist: UILabel!
    
//var delegate:CurrentTrackDelegate?
    var timeDelegate: TimeChanged?
    var timer = Timer()
    var timeObserveTK: AnyObject!
    
    var vkID: String = ""
    
var CurrentTrack = ["name":"","artist":"","id":-1,"default_id":0] as [String : Any]
let commandCenter = MPRemoteCommandCenter.shared()
   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        GetMusicTrack()
        self.TableSong.separatorStyle = .none
        ViewCurrentSong.isHidden = true
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.GoToPlayer(sender:)))
        self.ViewCurrentSong.addGestureRecognizer(gesture)
     
         self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bgall.png")!)
        NotificationCenter.default.addObserver(self, selector: #selector(MainPlayerVC.PlayNextSong),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
        
        setupAVAudioSession()
        
        
        print("this var")
        print(vkID)

        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func MD5(string: String) -> Data {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
// VK take hash for get music link
    public func GetMusicTrack() {
        self.playList.removeAll()
        let md5Data = MD5(string:"/method/audio.get?v=5.68&device_id=f8f11195ae1c5a17&uid=\(vkID)&access_token=71d8be6a5051f738e824b9a67fe4ac901253d7a8c75b9d2559114350047f8fadf199e8066c35f83182ee40be6228fc130f0ef2e")
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        
        
        let url = URL(string: "https://api.vk.com/method/audio.get?v=5.68&device_id=f8f11195ae1c5a17&uid=\(vkID)&access_token=71d8be6a5051f738e824b9a67fe4ac901253d7a8c75b9d2559114350047f8fadf199e8066c35f83182ee4&sig=\(md5Hex)")
        print("md5Hex: \(md5Hex)")
        
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("VKAndroidApp/4.13.1-1206 (Android 4.4.4; SDK 19; armeabi; ; ru)", forHTTPHeaderField: "User-Agent")
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) {data,response,error in
          
            do {
                let json = try? JSONSerialization.jsonObject(with: data!) as? [String:Any]
                print(json)
                if let json = try? JSONSerialization.jsonObject(with: data!) as? [String:Any],
                    let response = json?["response"] as? [String:Any],
                    let items = response["items"] as? [[String:Any]] {
                    
                    for songJson in items {
                        if let artist = songJson["artist"] as? String, let title = songJson["title"] as? String, let url = songJson["url"] as? String {
                         let Struct = Song(name: String(title), artist: String(artist), audioFile: String(url), state: SongState.undefined)
                            self.playList.append(Struct)
                            
                            if (self.playList.count > 1) {
                                self.TableSong.reloadData()
                    
                            }
                        
                        }
                        DispatchQueue.main.async() {
                            self.TableSong.reloadData()
                            self.CurrentTracks(id: 0)
                            self.ViewCurrentSong.isHidden = false
                            
                                    }
                        
                    }
                } else {
                    print("bad json - do some recovery")
                }
            
            
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        }
        
        
        task.resume()
  
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "protoCell", for: indexPath) as! TableCell
        
        if (self.playList.count > 1) {
            
            cell.SongName.text=playList[indexPath.row].name
            cell.SongArtist.text = playList[indexPath.row].artist
            cell.buttonPlay.tag = indexPath.row
            cell.buttonPlay.addTarget(self, action: #selector(self.ButtonChangeState(_:)), for: UIControlEvents.touchUpInside )
            cell.layer.backgroundColor = UIColor.clear.cgColor

            // Select state for button
            switch playList[indexPath.row].state {
            case .undefined:
                cell.buttonPlay.setImage(UIImage(named: "play.png"), for: .normal)
                print("undefined")
                
            case .playing:
                cell.buttonPlay.setImage(UIImage(named: "stop-paly.png"), for: .normal)
                print("playing")
            default:
                cell.buttonPlay.setImage(UIImage(named: "play.png"), for: .normal)
                print("default")
                break
            }
            
        } else {
            print("array of index")
        }

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "twoVC" else { return }
        guard let destination = segue.destination as? PlaySong else { return }
        
        if let indexPath =  TableSong.indexPathForSelectedRow {
            if (CurrentTrack["id"] as! Int != indexPath.row ) {
                PlaySongTrack(id: indexPath.row)
            }

        }
    
        destination.SongName = CurrentTrack["name"] as! String
        destination.delegate = self
        timeDelegate = destination
        
       

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "twoVC", sender: self)
    
    }
    
    func Play() {
        StopPlaySong()
    }
    func Next() {

        PlayNextSong()
    }
    func Prev(){
        PlayPrevSong()
    }

    func changeTime(value: Double) {
        if let duration = avPlayer?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            
            let value = Float64(value) * totalSeconds
            let seekTime = CMTimeMake(Int64(value), 1)
            
            avPlayer?.seek(to: seekTime, completionHandler: { (completedSeek) in
                
            })
        }
    }
    
    
    func timeObserver() {
        let interval = CMTimeMake(1, 2)
        timeObserveTK = avPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            
            let seconds = CMTimeGetSeconds(time)
            
            let secondsTime = Int(seconds.truncatingRemainder(dividingBy: 60.0))
            
            let MinutesTime =  Int(seconds/60)
            
            if let duration = self?.avPlayer?.currentItem?.duration {
                let durationTime = CMTimeGetSeconds(duration)
                let AllTime = self?.avPlayer?.currentItem?.duration.seconds
                var min = "0:00"
                var startTimeHere = "0:00"
                
                if ((AllTime?.isNaN)!) {
                    print("is nana")
                } else {
                    let durationMin = (Int(AllTime!) % 3600) / 60
                    let durationSec = (Int(AllTime!) % 3600) % 60
                    min = "\(durationMin):\(durationSec)"
                    startTimeHere = "\(MinutesTime):\(secondsTime)"
                }
                
                print("time observ " + String(describing: time))
                
                
                self?.timeDelegate?.changeTimeSlider(time: Float(seconds / durationTime), start: startTimeHere, duration: String(min))
                
                
            }
            print("ok")
            
            } as AnyObject

    }
    func GoToPlayer(sender : UITapGestureRecognizer) {
              performSegue(withIdentifier: "twoVC", sender: self)
    }
    
  
    
    func ButtonChangeState (_ sender:UIButton) {
        guard let cell = sender.findClass(type: TableCell.self) else {return}
        guard let indexPath = self.TableSong.indexPath(for: cell) else { return }
        let thisSong = CurrentTrack["id"] as! Int
        let DefaultSong = CurrentTrack["default_id"] as! Int
        if (playList[indexPath.row].state == .undefined && thisSong != sender.tag) {
            playList[indexPath.row].state = .playing
            for  i in 0...playList.count-1 {
                if (i != indexPath.row) {
                    playList[i].state = .undefined
                }

            }
            PlaySongTrack(id: sender.tag)
            sender.setImage(UIImage(named: "stop-paly.png"), for: UIControlState.normal)
            
        }  else if (playList[indexPath.row].state == .playing) {
            playList[indexPath.row].state = .undefined
            avPlayer?.pause()
            print("else if 1")
        } else if (playList[indexPath.row].state == .undefined && thisSong == sender.tag) {
            playList[indexPath.row].state = .playing
            if (DefaultSong == 0) {
                PlaySongTrack(id: sender.tag)
                self.CurrentTrack.updateValue(-1, forKey: "default_id")
            }
            avPlayer?.play()
            print("else if 2" + String(thisSong))

        }
        
        self.TableSong.reloadData()
            }
    
    private func setupAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            debugPrint("AVAudioSession is Active and Category Playback is set")
            UIApplication.shared.beginReceivingRemoteControlEvents()
            setupCommandCenter()
        } catch {
            debugPrint("Error: \(error)")
        }
    }
    
    private func setupCommandCenter() {

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(self.changedThumbSlider(_:)))
       
        
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.avPlayer?.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.avPlayer?.pause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.PlayNextSong()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.PlayPrevSong()
            return .success
        }
    }
    
    
    func changedThumbSlider(_ event: MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        return .success
    }
    
    func PlaySongTrack(id:Int) {
       self.avPlayer?.removeTimeObserver(timeObserveTK)
        CurrentTracks(id: id)
        self.TableSong.reloadData()
        self.CurrentTrack.updateValue(id, forKey: "id")
        self.CurrentTrack.updateValue(playList[id].name, forKey: "name")
        self.CurrentTrack.updateValue(playList[id].artist, forKey: "artist")
        
        for  i in 0...playList.count-1 {
            playList[i].state = .undefined
        }
        self.playList[id].state = .playing
        let userInfo = ["item": playList[id].name]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object: nil, userInfo: userInfo)
        
        

        let url = URL(string: playList[id].audioFile)
        let playerItem: AVPlayerItem = AVPlayerItem(url: url!)
        avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer?.automaticallyWaitsToMinimizeStalling = false
        avPlayer?.play()
     
        
        let songInfo : [String : Any] = [MPMediaItemPropertyTitle : playList[id].name, MPNowPlayingInfoPropertyPlaybackRate : 1, MPMediaItemPropertyArtist : playList[id].artist]
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = songInfo
        
        if (avPlayer?.currentItem?.status != nil) {
           timeObserver()
        }
       
           }
    
    func PlayNextSong() {
        let songNext = CurrentTrack["id"] as! Int
        if (songNext < playList.count-1) {
            for  i in 0...playList.count-1 {
                playList[i].state = .undefined
            }
            self.playList[songNext+1].state = .playing
 
            PlaySongTrack(id: songNext + 1)
            
        } else {
            PlaySongTrack(id: songNext)
  
        }
        
        
            }
    
    func PlayPrevSong() {
        (childViewControllers.first as? CurrentTrackVC)?.curentName.text = "Hello"
        let songNext = CurrentTrack["id"] as! Int
        if (songNext > 0) {
            for  i in 0...playList.count-1 {
                playList[i].state = .undefined
            }
            self.playList[songNext-1].state = .playing
            PlaySongTrack(id: songNext - 1)
        } else {
            PlaySongTrack(id: songNext)
        }
        
        
        
    }
    
    func CurrentTracks(id:Int) {
        cs_name.text = playList[id].name
        cs_artist.text = playList[id].artist
     
    }
  
    
    @IBAction func NextTrack(_ sender: Any) {
        PlayNextSong()
    }
  
    @IBAction func PrevTrack(_ sender: Any) {
        PlayPrevSong()
    }
    
    @IBAction func StopPlay(_ sender: Any) {
      StopPlaySong()
        
    }
    
    func StopPlaySong () {
        var idSong = CurrentTrack["id"] as! Int
        if (idSong == -1) {
            idSong = 0
        }
        if (playList[idSong].state == .undefined) {
            playList[idSong].state = .playing
            if (avPlayer?.currentItem?.status == nil) {PlaySongTrack(id: idSong)}
            avPlayer?.play()
            self.TableSong.reloadData()
            print("PLAY")
        } else {
            playList[idSong].state = .undefined
            avPlayer?.pause()
          
            self.TableSong.reloadData()
            print("PAYSE")
        }
    }
    
  
    
  
    
}



extension UIView {
    func findClass<T>(type: T.Type) -> T? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let view = parentResponder as? T {
                return view
            }
        }
        return nil
    }
}



