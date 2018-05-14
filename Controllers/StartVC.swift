//
//  StartVC.swift
//  VKMusicApp
//
//  Created by Алексей  Червон  on 14.01.18.
//  Copyright © 2018 eInternetFunAlexChervon. All rights reserved.
//  Стартовый контроллер

import UIKit

class StartVC: UIViewController {
var result = ""
    weak var nsq:NSNumber? = 0
    var userInfo = ["first_name":"","last_name":"","uid":0] as [String : Any]
    @IBOutlet weak var textfield: UITextField!
    typealias CompletionHandler = (_ success:Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "sendID" else { return }
        guard let destination = segue.destination as? MainPlayerVC else { return }
        destination.vkID = textfield.text!
        
    }
    
    @IBAction func goNext(_ sender: Any) {
        performSegue(withIdentifier: "sendID", sender: self)
    }
    
    @IBAction func gobyAlex(_ sender: Any) {
        textfield.text = "97257820"
        performSegue(withIdentifier: "sendID", sender: self)
    }
    
 
    func getUserInfo(id:String ,finished: () -> Void) -> NSNumber {
        let url = URL(string: "https://api.vk.com/api.php?oauth=1&method=users.get&user_ids=\(id)")
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in

            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                if let response = json["response"] as? [[String:AnyObject]] {
                    for info in response {
                        if let name = info["first_name"] as? String, let last_name = info["last_name"] as? String {
                            self.userInfo.updateValue(name, forKey: "first_name")
                            self.userInfo.updateValue(last_name, forKey: "last_name")
                            self.userInfo.updateValue(info["uid"] as! NSNumber, forKey: "uid")
                            //number = self.userInfo["uid"] as! NSNumber
                            self.nsq = 12
                            
                        }
                        
                    }
                    
                   
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            
        })
        
        
        task.resume()
        
        finished()
        
        return nsq!
   }

}
