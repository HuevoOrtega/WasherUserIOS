//
//  HistoryController.swift
//  Vashen
//
//  Created by Alan on 7/31/16.
//  Copyright © 2016 Alan. All rights reserved.
//

import Foundation

class HistoryController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarLeftButton: UIBarButtonItem!
    
    var idClient:String!
    var services: [Service] = []
    var imagesMap:[UIImage] = []
    var imageMapSet:[Int] = []
    var imagesCleaner:[UIImage] = []
    var imageCleanerSet:[Int] = []
    
    override func viewWillAppear(_ animated: Bool) {
        initValues()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if let barFont = UIFont(name: "PingFang TC", size: 17) {
            self.navigationBar.titleTextAttributes = [ NSFontAttributeName: barFont]
        }
        if let buttonFont = UIFont(name: "PingFang TC", size: 14) {
            self.navigationBarLeftButton.setTitleTextAttributes([ NSFontAttributeName: buttonFont], for: .normal)
        }
    }
    
    func initValues() {
        services = DataBase.getFinishedServices()
        for _ in services {
            imagesMap.append(UIImage())
            imageMapSet.append(0)
            imagesCleaner.append(UIImage())
            imageCleanerSet.append(0)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let service = self.services[indexPath.row]
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryRowTableViewCell
        let format = DateFormatter()
        format.dateFormat = "yyy-MM-dd HH:mm:ss"
        format.locale = Locale(identifier: "us")
        cell.date.text = format.string(from: service.acceptedTime)
        cell.serviceType.text = service.service + " $" + service.price
        if imageCleanerSet[indexPath.row] == 0 {
            cell.cleanerImage.image = nil
            DispatchQueue.global().async {
                self.setCleanerImage(image: cell.cleanerImage, withId: service.cleanerId, withPosition: indexPath.row)
            }
        } else {
            cell.cleanerImage.image = imagesCleaner[indexPath.row]
        }
        if imageMapSet[indexPath.row] == 0 {
            cell.locationImage.image = nil
            DispatchQueue.global().async {
                self.setMapImage(map: cell.locationImage, withService: service, withPosition: indexPath.row)
            }
        } else {
            cell.locationImage.image = imagesMap[indexPath.row]
        }
        return cell
    }
    
    func setMapImage(map: UIImageView, withService service:Service!, withPosition position:Int){
        let urlString = "https://maps.googleapis.com/maps/api/staticmap?center=\(service.latitud),\(service.longitud)&markers=color:red%7Clabel:S%7C\(service.latitud),\(service.longitud)&zoom=15&size=640x260&key=AIzaSyBRop6_RztxsuXASY-CftdFtMwAuFbG2Q4"
        let url = URL(string: urlString)! as URL
        do {
        let data = try Data(contentsOf: url)
        map.image = UIImage(data: data)
            imagesMap[position] = map.image!
            imageMapSet[position] = 1
        } catch {}
    }
    
    func setCleanerImage(image:UIImageView, withId id: String, withPosition position:Int){
        let url = URL(string: "http://54.218.50.2/api/imagenes/lavadores/" + id + "/profile_image.jpg")!
        do {
            let data = try Data(contentsOf: url)
            image.image = UIImage(data: data)
            imagesCleaner[position] = image.image!
            imageCleanerSet[position] = 1
        } catch {
            image.image = UIImage(named: "default_image")
            imagesCleaner[position] = image.image!
            imageCleanerSet[position] = 1
        }

    }
    
    
    @IBAction func clickedCancel(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}
