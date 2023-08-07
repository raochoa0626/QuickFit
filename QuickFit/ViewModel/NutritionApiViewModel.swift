//
//  NutritionApiViewModel.swift
//  QuickFit
//
//  Created by Josh Thompson on 11/17/22.
//

import Foundation

class NutritionApiViewModel: ObservableObject{
    
    @Published var recommendations = RecipeRecommendation(recipes: [], nutrition: Nutrition(items: []))
    
    func fetchRecipe(search: String) {
        let convertedSearch = search.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://api.spoonacular.com/recipes/complexSearch?apiKey=deb0964a630041bfaf28832391b792f9&query=\(convertedSearch)&instructionsRequired=true&addRecipeInformation=true&fillIngredients=true"
        
        print("URL: \(urlString)")
        
        guard let url = NSURL(string: urlString) as? URL
        else
        {
            self.recommendations.recipes = []
            return
        }
        
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            guard let data = data, error == nil else { return }
            
            if (error != nil) {
                print("ERROR: \(error!)")
            } else {
                do{
                    let decoded = try JSONDecoder().decode(Response.self, from: data)
                    DispatchQueue.main.async {
                        self.recommendations.recipes = decoded.results
                    }
                }
                catch {
                    print(error)
                }
            }
        })
        
        dataTask.resume()
    }
    
    func fetchNutrition(search : String)
    {
        DispatchQueue.main.async {
            let query = search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: "https://api.calorieninjas.com/v1/nutrition?query=\(query!)")!
            var request = URLRequest(url: url)
            request.setValue("QXNxvbMmDoeoWwUlipzG+g==atrNTIhykxTg9vQ0", forHTTPHeaderField: "X-Api-Key")
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                guard let data = data else { return }

                if(error != nil) {
                    print("Error: \(error!)")
                }
                else{
                    do{
                        let decoded = try JSONDecoder().decode(Nutrition.self, from: data)
                        DispatchQueue.main.async {
                            self.recommendations.nutrition = decoded
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            }
            task.resume()
        }
    }
    
}
