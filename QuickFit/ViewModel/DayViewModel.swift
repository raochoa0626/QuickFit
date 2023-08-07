//
//  DayViewModel.swift
//  QuickFit
//
//  Created by Jaden Puckett on 11/15/22.
//

import Foundation
import Firebase
import SwiftUI
import SwiftUICharts

// FireBase stuffs
class DayViewModel: ObservableObject {
    @Published var days: [Day] = []
    @Published var currentDay = ""
    
    init() {
        fetchDays()
    }
    
    // used in rec view
    func addWeightLiftToLatestDay(instr:String, name:String, reps:Int, sets:Int, weight:Double) {
        // use the most recent day for adding
        let dayNum = days[days.count-1].dayNum
        let liftCount = numberOfLiftsOrCardiosInDay(dayNum: dayNum, isLift: true)
        let liftNum = liftCount + 1

        let newWeightLift = WeightLift(liftNum: liftNum, name: name, instruction: instr, weight: weight, sets: sets, reps: reps)
        
        for i in 0..<days.count
        {
            if(days[i].dayNum == dayNum)
            {
                days[i].lifts.append(newWeightLift)
            }
        }
        
        let db = Firestore.firestore()
        let dayString = "Day" + "\(dayNum)"
        let liftString = "Lift" + "\(liftNum)"
        let docRef = db.collection("Days").document(dayString).collection("Lifts").document(liftString)
        docRef.setData(["instruction":instr,"name":name,"reps":reps,"sets":sets,"setsFinished":0,"weight":weight,"liftNum":liftNum]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document successfully added!")
            }
        }
        fetchDays()
    }
    
    func updateCardioTime(cardioNum:Int,dayNum:Int,hours:Int,min:Int,sec:Int) {
        let db = Firestore.firestore()
        let dayString = "Day" + "\(dayNum)"
        let daysRef = db.collection("Days").document(dayString)
        let cardioString = "Cardio" + "\(cardioNum)"
        let cardioRef = daysRef.collection("Cardios").document(cardioString)
        cardioRef.updateData(["hours":hours,"minutes":min,"seconds":sec]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
        fetchDays()
    }
    
    func updateLiftSetsFinished(liftNum:Int,dayNum:Int,setsFin:Int) {
        let db = Firestore.firestore()
        let dayString = "Day" + "\(dayNum)"
        let daysRef = db.collection("Days").document(dayString)
        let liftString = "Lift" + "\(liftNum)"
        let liftsRef = daysRef.collection("Lifts").document(liftString)
        liftsRef.updateData(["setsFinished":setsFin]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
        fetchDays()
    }
    
    func updateLiftSetsRepsWeight(liftNum:Int,dayNum:Int,sets:Int,reps:Int,weight:Double) {
        let db = Firestore.firestore()
        let dayString = "Day" + "\(dayNum)"
        let daysRef = db.collection("Days").document(dayString)
        let liftString = "Lift" + "\(liftNum)"
        let liftsRef = daysRef.collection("Lifts").document(liftString)
        liftsRef.updateData(["sets":sets,"reps":reps,"weight":weight]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
        fetchDays()
    }
    
    func deleteCardio(cardioNum:Int,dayNum:Int) {
        for day in self.days {
            if dayNum == day.dayNum {
                for cardio in day.cardios {
                    if cardioNum == cardio.cardioNum {
                        let db = Firestore.firestore()
                        let dayString = "Day" + "\(dayNum)"
                        let cardioString = "Cardio" + "\(cardioNum)"
                        db.collection("Days").document(dayString).collection("Cardios").document(cardioString).delete() { error in
                            if let error = error {
                                print("Error deleting document: \(error)")
                            } else {
                                print("Document successfully deleted!")
                            }
                        }
                    }
                }
            }
        }
        fetchDays()
    }
    
    func deleteLift(liftNum:Int,dayNum:Int) {
        for day in self.days {
            if dayNum == day.dayNum {
                for lift in day.lifts {
                    if liftNum == lift.liftNum {
                        let db = Firestore.firestore()
                        let dayString = "Day" + "\(dayNum)"
                        let liftString = "Lift" + "\(liftNum)"
                        db.collection("Days").document(dayString).collection("Lifts").document(liftString).delete() { error in
                            if let error = error {
                                print("Error deleting document: \(error)")
                            } else {
                                print("Document successfully deleted!")
                            }
                        }
                    }
                }
            }
        }
        fetchDays()
    }
    
    func addCardio(instr:String,name:String,hours:Int,min:Int,sec:Int,dayNum:Int) {
        let db = Firestore.firestore()
        let dayString = "Day" + "\(dayNum)"
        let cardioCount = numberOfLiftsOrCardiosInDay(dayNum: dayNum, isLift: false)
        let cardioNum = cardioCount + 1
        let cardioString = "Cardio" + "\(cardioNum)"
        let docRef = db.collection("Days").document(dayString).collection("Cardios").document(cardioString)
        docRef.setData(["instruction":instr,"name":name,"hours":hours,"minutes":min,"seconds":sec,"cardioNum":cardioNum]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document successfully added!")
            }
        }
        fetchDays()
    }
    
    // find the lifts or cardios count in corresponding day
    func numberOfLiftsOrCardiosInDay(dayNum:Int,isLift:Bool) -> Int {
        for day in self.days {
            if dayNum == day.dayNum {
                if isLift {
                    return day.lifts.count
                } else {
                    return day.cardios.count
                }
            }
        }
        return 0
    }
    
    func addWeightLift(instr:String, name:String, reps:Int, sets:Int, weight:Double, dayNum:Int) {
        let liftCount = numberOfLiftsOrCardiosInDay(dayNum: dayNum, isLift: true)
        let liftNum = liftCount + 1

        let newWeightLift = WeightLift(liftNum: liftNum, name: name, instruction: instr, weight: weight, sets: sets, reps: reps)
        
        for i in 0..<days.count
        {
            if(days[i].dayNum == dayNum)
            {
                days[i].lifts.append(newWeightLift)
            }
        }
        
        let db = Firestore.firestore()
        let dayString = "Day" + "\(dayNum)"
        let liftString = "Lift" + "\(liftNum)"
        let docRef = db.collection("Days").document(dayString).collection("Lifts").document(liftString)
        docRef.setData(["instruction":instr,"name":name,"reps":reps,"sets":sets,"setsFinished":0,"weight":weight,"liftNum":liftNum]) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document successfully added!")
            }
        }
        fetchDays()
    }
    
    func setCalories(cal: Int, dayN: Int) {
        let db = Firestore.firestore()
        let dayString = "Day" + "\(dayN)"
        let docRef = db.collection("Days").document(dayString)
        docRef.updateData(["calories":cal]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated!")
            }
        }
        fetchDays()
    }
    
    func getDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from:date)
    }
    
    func addDay() {
        let date = getDate()
        let dayNum = days.count + 1
        let liftList: [WeightLift] = []
        let cardioList: [Cardio] = []
        let calories = 0
        
        let newDay = Day(dayNum: dayNum, cardios: cardioList, lifts: liftList, calories: calories, date: date)
        
        // add to days array
        days.append(newDay)
        
        // add to firebase
        let db = Firestore.firestore()
        let dayString = "Day" + "\(dayNum)"
        let docRef = db.collection("Days").document(dayString)
        docRef.setData(["calories":calories, "date":date, "dayNum":dayNum]) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
            }
        }
        fetchDays()
    }
    
    func fetchDays() {
        days.removeAll()
        let db = Firestore.firestore()
        let ref = db.collection("Days")
        
        ref.getDocuments { snapshot, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            if let snapshot = snapshot {
                // outer search to get days
                for document in snapshot.documents {
                    let data = document.data()
                    //print(data)
                    
                    let dayNum = data["dayNum"] as? Int ?? 7
                    let calories = data["calories"] as? Int ?? 0
                    let date = data["date"] as? String ?? ""
                    var day = Day(dayNum: dayNum, cardios: [], lifts: [], calories: calories, date: date)
                    
                    // internal search to get lifts for each day - takes longer time
                    let dayString = "Day" + "\(dayNum)"
                    ref.document(dayString).collection("Lifts").getDocuments { snapshot, error in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            return
                        }
                        if let snapshot = snapshot {
                            for document in snapshot.documents {
                                let data = document.data()
                                //print(data)
                                let instr = data["instruction"] as? String ?? ""
                                let name = data["name"] as? String ?? ""
                                let reps = data["reps"] as? Int ?? 0
                                let sets = data["sets"] as? Int ?? 0
                                let setsF = data["setsFinished"] as? Int ?? 0
                                let weight = data["weight"] as? Double ?? 0.0
                                let liftNum = data["liftNum"] as? Int ?? 100000
                                
                                let lift = WeightLift(liftNum: liftNum, name: name, instruction: instr, weight: weight, sets: sets, reps: reps, setsFinished: setsF)
                                day.lifts.append(lift)
                            }
                        }
                        // FINAL APPENDING OF THE DAY - Must happen within the lifts fetching because it takes longer than cardios fetching - Day append happens after fetching both lifts and cardios
                        self.days.append(day)
                        //sort the days array to have most recent day first
                        self.days = self.days.sorted(by: { $0.dayNum < $1.dayNum})
                    }
                    // internal search to get cardios for each day - takes shorter time
                    ref.document(dayString).collection("Cardios").getDocuments { snapshot, error in
                        guard error == nil else {
                            print(error!.localizedDescription)
                            return
                        }
                        if let snapshot = snapshot {
                            for document in snapshot.documents {
                                let data = document.data()
                                //print(data)
                                let name = data["name"] as? String ?? ""
                                let instr = data["instruction"] as? String ?? ""
                                let hours = data["hours"] as? Int ?? 0
                                let minutes = data["minutes"] as? Int ?? 0
                                let seconds = data["seconds"] as? Int ?? 0
                                let cardioNum = data["cardioNum"] as? Int ?? 0
                                
                                let cardio = Cardio(cardioNum: cardioNum, name: name, instruction: instr, hours: hours, minutes: minutes, seconds: seconds)
                                day.cardios.append(cardio)
                            }
                        }
                    }
                } // end of outer for
            }
        }
        
    } // end of fetchDays()
    
    func getDailySetsCompletedChart(day:Day) -> ChartData
    {
        var names: [String] = []
        var setsComp: [Int] = []
        
        for lift in day.lifts
        {
            let maxCount = 12
            var liftName = ""
            
            if(lift.name.count > maxCount)
            {
                liftName = "\(lift.name.prefix(maxCount - 1))..."
            }
            else
            {
                liftName = lift.name
            }
            names.append(liftName)
            setsComp.append(lift.setsFinished)
        }
        
        // make the chart data
        var data: [(String, Int)] = []
        for i in 0..<names.count {
            data.append((names[i], setsComp[i]))
        }
        print(data)
        let result = ChartData(values: data)
        
        return result
    }
    
    func getWeeklySetsCompletedChart() -> [Double]
    {
        var result : [Double] = []
        var currentDaySetsComp = 0
        
        for day in days
        {
            for lift in day.lifts
            {
                currentDaySetsComp += lift.setsFinished
            }
            result.append(Double(currentDaySetsComp))
            currentDaySetsComp = 0
        }
        
//        print("weekly sets comp: " + "\(result)")
        return result
    }
    
    func getWeeklyNutritionChart() -> [Double]
    {
        var result : [Double] = []
        
        for day in days
        {
            result.append(Double(day.calories))
        }
        
        return result
    }
    
    func getNutritionRate() -> Int
    {
        var total = 0.0
        var average = 0.0
        var percentage = 0.0
        
        if(!days.isEmpty)
        {
            // From start to second to the last element
            for i in 0..<days.count - 1
            {
                total += Double(days[i].calories)
            }
            
            average = total / Double(days.count - 1)
            percentage = (Double(days[days.count - 1].calories) / average) * 100
            
            if(percentage < 100)
            {
                percentage = -percentage
            }
            else
            {
                percentage -= 100
            }
        }
        
        return Int(percentage)
    }
}

func fixCardioTime(cardio : Cardio) -> String
{
    var result = ""
    
    if(cardio.hours < 10 && cardio.hours > 0)
    {
        result += "0\(cardio.hours):"
    }
    else if(cardio.hours >= 10)
    {
        result += "\(cardio.hours):"
    }
    else if(cardio.hours == 0)
    {
        result += "00:"
    }
    
    if(cardio.minutes < 10 && cardio.minutes > 0)
    {
        result += "0\(cardio.minutes):"
    }
    else if(cardio.minutes >= 10)
    {
        result += "\(cardio.minutes):"
    }
    else if(cardio.minutes == 0)
    {
        result += "00:"
    }
    
    if(cardio.seconds < 10 && cardio.seconds > 0)
    {
        result += "0\(cardio.seconds)"
    }
    else if(cardio.seconds >= 10)
    {
        result += "\(cardio.seconds)"
    }
    else if(cardio.seconds == 0)
    {
        result += "00"
    }
    
    return result
}

func getDayDate(day : String) -> String
{
    let result = day.components(separatedBy: " at ")
    return result[0];
}

func getDayTime(day : String) -> String
{
    let result = day.components(separatedBy: " at ")
    return result[1];
}

func workoutTypeToString(type: workoutType) -> String
{
    if(type == workoutType.weightlift) { return "Weight Lift" }
    else { return "Cardio" }
}

func getDummyWorkouts() -> [String]
{
    return [ "Workout Recommendation 1",
            "Workout Recommendation 2",
            "Workout Recommendation 3",
            "Workout Recommendation 4",
            "Workout Recommendation 5",
            "Workout Recommendation 6"]
}
