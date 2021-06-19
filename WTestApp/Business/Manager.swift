//
//  Manager.swift
//  PostCodeApp
//
//  Created by Alexandre Carvalho on 16/06/2021.
//

import Foundation
import Alamofire

class Manager {
    
    func downloadCSVData(completionHandler: @escaping (_ success: Bool) -> Void) {
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        let url = "https://raw.githubusercontent.com/centraldedados/codigos_postais/master/data/codigos_postais.csv"

        AF.download(
            url,
            method: .get,
            encoding: JSONEncoding.default,
            to: destination).response(completionHandler: { response in
                
                print("CSV Download is completed")
                completionHandler(true)
            })
    }
}
