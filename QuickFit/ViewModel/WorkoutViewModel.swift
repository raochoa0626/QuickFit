//
//  WrokoutAPIViewModel.swift
//  QuickFit
//
//  Created by Ramon Ochoa on 11/25/22.
//

import Foundation

class WorkoutApiViewModel: ObservableObject{
    
    @Published var workoutRec = WorkoutRecommendation(workouts: [])
    
    func fetchData(search: String) {
        
        let headers = [
            "X-RapidAPI-Key": "92632ef2f3mshd6866b56774f49bp15704ajsn8bbdfbf3b805",
            "X-RapidAPI-Host": "exercises-by-api-ninjas.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://exercises-by-api-ninjas.p.rapidapi.com/v1/exercises?muscle=\(search)")! as URL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard let data = data, error == nil else { return }
            
            print(data)
            
            if (error != nil) {
                print("ERROR: \(error!)")
            } else {
                do{
                    let decoded = try JSONDecoder().decode([Workout].self, from: data)
                    DispatchQueue.main.async {
                        self.workoutRec.workouts = decoded
                        print(decoded)
                    }
                }
                catch {
                    print(error)
                }
            }
        })
        dataTask.resume()
    }
    
}

