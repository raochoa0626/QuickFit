//
//  Workout.swift
//  Project Draft
//
//  Created by Gene Sanmillan on 10/23/22.
//

import SwiftUI

struct MainWorkoutView : View
{
    @EnvironmentObject var dayViewModel: DayViewModel
    
    var body: some View
    {
        NavigationStack {
            VStack {
                LineChartView(data: dayViewModel.getWeeklySetsCompletedChart(), title: "Weekly Analysis", legend: "Lift Sets Completed", style: Styles.quickFitLightMode, form: ChartForm.extraLarge, rateValue: 0).padding()
                
                List {
                    ForEach(dayViewModel.days.reversed()) { day in
                        NavigationLink(destination: WorkoutListView(day: day),
                            label: {
                                VStack(alignment: .leading)
                                {
                                    Text("\(getDayDate(day: day.date))").bold().foregroundColor(.primary)
                                    Text("\(day.lifts.count + day.cardios.count) Workouts")
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                }
                            })
                    }
                }
                .background(Color(UIColor.systemBackground))
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Workout").font(.system(size: 25, weight: .bold))
                        Spacer()
                        // Add Button
                        Button { dayViewModel.addDay()
                        } label: {
                            HStack
                            {
                                Label("", systemImage: "plus")
                                Text("Day")
                            }
                        }.buttonStyle(QuickFitPlusButton())

                    } // End of HStack
                }
            } // End of .toolbar | VStack
        }.accentColor(.primary) // End of NavigationStack
    }
}

struct WorkoutListView : View
{
    @EnvironmentObject var dayViewModel: DayViewModel
    @State var day : Day
    @State var addView = false
    @State var liftViewIsPresented = false
    @State var cardioViewIsPresented = false
    @State private var workoutView = workoutType.weightlift
    @State var selectedLift : WeightLift = WeightLift(liftNum: -1, name: "", instruction: "", weight: -1, sets: -1, reps: -1)
    @State var selectedCardio : Cardio = Cardio(cardioNum: -1, name: "", instruction: "", hours: -1, minutes: -1, seconds: -1)
    
    var body: some View
    {
        NavigationStack
        {
            Text("\(getDayTime(day: day.date))").frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 50).foregroundColor(.secondary)
            
            VStack {
                BarChartView(data: dayViewModel.getDailySetsCompletedChart(day: day), title: "Lift Sets Completed", style: Styles.quickFitLightMode, form: ChartForm.extraLarge)
            }
            .padding(10)
            .padding(.bottom, 15)
            
            Picker("View", selection: $workoutView)
            {
                Text("Weight Lifts").tag(workoutType.weightlift)
                Text("Cardio").tag(workoutType.cardio)
            }.pickerStyle(.segmented).padding(.horizontal)
            
            VStack
            {
                if(workoutView == workoutType.weightlift)
                {
                    VStack {
                        List {
                            ForEach(day.lifts)
                            { lift in
                                Button {
                                    selectedLift = lift
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                                    {
                                        liftViewIsPresented = true
                                    }

                                } label: {
                                    VStack(alignment: .leading)
                                    {
                                        Text("\(lift.name)").bold()
                                        Text("\(lift.sets)x\(lift.reps)")
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .sheet(isPresented: $liftViewIsPresented, onDismiss:
                                {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                                    {
                                        day = dayViewModel.days[day.dayNum - 1]
                                    }
                                })
                                { WeightLiftView(dayNum: day.dayNum, weightLift: $selectedLift, presented: $liftViewIsPresented) }
                            }
                        }
                        .background(Color(UIColor.systemBackground))
                        .scrollContentBackground(.hidden)
                    }
                }
                else
                {
                    VStack {
                        List {
                            ForEach(day.cardios) { cardio in
                                Button {
                                    selectedCardio = cardio
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                                    {
                                        cardioViewIsPresented = true
                                    }
                                } label: {
                                    VStack(alignment: .leading)
                                    {
                                        Text("\(cardio.name)").bold()
                                        Text("\(fixCardioTime(cardio: cardio))")
                                            .font(.system(size: 15))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .sheet(isPresented: $cardioViewIsPresented, onDismiss: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                                    {
                                        day = dayViewModel.days[day.dayNum - 1]
                                    }
                                }){ CardioView(dayNum: day.dayNum, cardio: $selectedCardio, cardioViewIsPresented: $cardioViewIsPresented) }
                            }
                        }
                        .background(Color(UIColor.systemBackground))
                        .scrollContentBackground(.hidden)
                    }
                }
            }.navigationBarTitleDisplayMode(.inline)
                .toolbar
                {
                    ToolbarItem(placement: .principal)
                    {
                        HStack
                        {
                            Text("\(getDayDate(day: day.date))").font(.system(size: 25, weight: .bold))

                            Spacer()

                            // Add Button
                            Button
                            {
                                addView = true
                            } label:
                            {
                                HStack
                                {
                                    Label("", systemImage: "plus")
                                    Text("Workout")
                                }
                                
                            }
                            .buttonStyle(QuickFitPlusButton())
                            .sheet(isPresented: $addView, onDismiss: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                                {
                                    day = dayViewModel.days[day.dayNum - 1]
                                }
                            }){ AddWorkoutView(addView: $addView, day:day) }
                            
                        } // End of HStack
                    }
                } // End of .toolbar | VStack
        } // End of NavigationStack
    }
}

struct WeightLiftView : View
{
    @EnvironmentObject var dayViewModel: DayViewModel
    @State var dayNum : Int
    @Binding var weightLift : WeightLift
    @Binding var presented : Bool
    @State private var showDeleteAlert = false
    @State private var showEditLiftAlert = false
    @State private var showEditCompAlert = false
    @State private var sets = 0
    @State private var reps = 0
    @State private var weight = 0.0
    @State private var setsFin = 0
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            HStack {
                Text(weightLift.name).font(.system(size: 25, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button {
                    self.showDeleteAlert.toggle()
                } label: { Text("Delete") }
                .buttonStyle(QuickFitDeleteButton())
                .alert("Are you sure?", isPresented: $showDeleteAlert) {
                    Button("Delete") {
                        dayViewModel.deleteLift(liftNum: weightLift.liftNum, dayNum: dayNum)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            presented = false
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
            Text("Weight Lift").foregroundColor(.secondary)
            
            Divider()
            
            VStack(alignment: .center, spacing: 10)
            {
                HStack {
                    Spacer()
                    Button {
                        sets = weightLift.sets
                        reps = weightLift.reps
                        weight = weightLift.weight
                        self.showEditLiftAlert.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(QFButtonColor.customBlue)
                            .font(.system(size: 25))
                            .padding(.top, 5)
                    }
                    .alert("", isPresented: $showEditLiftAlert) {
                        TextField("", value: $sets, format: .number)
                        TextField("", value: $reps, format: .number)
                        TextField("", value: $weight, format: .number)
                        Button("Confirm", role: .cancel) {
                            dayViewModel.updateLiftSetsRepsWeight(liftNum: weightLift.liftNum, dayNum: dayNum, sets: sets, reps: reps, weight: weight)
                            sets = 0
                            reps = 0
                            weight = 0.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                            {
                                self.weightLift = dayViewModel.days[dayNum-1].lifts[weightLift.liftNum-1]
                            }
                        }
                    }
                }
                Text("Sets:").frame(maxWidth: .infinity)
                Text("\(weightLift.sets)").font(.system(size: 50, weight: .bold))
                Text("Reps:")
                Text("\(weightLift.reps)").font(.system(size: 50, weight: .bold))
                Text("Weight:")
                Text("\(weightLift.weight, specifier: "%.2f")").font(.system(size: 50, weight: .bold))
            }
            Divider()
            ScrollView
            {
                Text("\(weightLift.instruction)")
            }
            Divider()
            VStack(alignment: .center, spacing: 10)
            {
                HStack {
                    Spacer()
                    Button {
                        setsFin = weightLift.setsFinished
                        self.showEditCompAlert.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(QFButtonColor.customBlue)
                            .font(.system(size: 25))
                            .padding(.top, 5)
                    }
                    .alert("", isPresented: $showEditCompAlert) {
                        TextField("", value: $setsFin, format: .number)
                        Button("Confirm", role: .cancel) {
                            dayViewModel.updateLiftSetsFinished(liftNum: weightLift.liftNum, dayNum: dayNum, setsFin: setsFin)
                            setsFin = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                            {
                                self.weightLift = dayViewModel.days[dayNum-1].lifts[weightLift.liftNum-1]
                            }
                        }
                    }
                }
                Text("Sets Completed:").frame(maxWidth: .infinity)
                Text("\(weightLift.setsFinished)").font(.system(size: 50, weight: .bold))
            }
            Spacer()
        }.padding()
    } // end of body
}

struct CardioView : View
{
    @EnvironmentObject var dayViewModel: DayViewModel
    @State var dayNum : Int
    @Binding var cardio : Cardio
    @State private var showDeleteAlert = false
    @Binding var cardioViewIsPresented : Bool
    @State private var showEditCardioTimeAlert = false
    @State var hours = 0
    @State var min = 0
    @State var sec = 0
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            HStack {
                Text(cardio.name).font(.system(size: 25, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Button {
                    self.showDeleteAlert.toggle()
                } label: { Text("Delete") }
                .buttonStyle(QuickFitDeleteButton())
                .alert("Are you sure?", isPresented: $showDeleteAlert) {
                    Button("Delete") {
                        dayViewModel.deleteCardio(cardioNum: cardio.cardioNum, dayNum: dayNum)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            cardioViewIsPresented = false;
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
            Text("Cardio").foregroundColor(.secondary)
            
            Divider()
            
            VStack(alignment: .center)
            {
                HStack {
                    Spacer()
                    Button {
                        hours = cardio.hours
                        min = cardio.minutes
                        sec = cardio.seconds
                        self.showEditCardioTimeAlert.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(QFButtonColor.customBlue)
                            .font(.system(size: 25))
                            .padding(.top, 5)
                    }
                    .alert("", isPresented: $showEditCardioTimeAlert) {
                        TextField("", value: $hours, format: .number)
                        TextField("", value: $min, format: .number)
                        TextField("", value: $sec, format: .number)
                        Button("Confirm", role: .cancel) {
                            dayViewModel.updateCardioTime(cardioNum: cardio.cardioNum, dayNum: dayNum, hours: hours, min: min, sec: sec)
                            hours = 0
                            min = 0
                            sec = 0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                            {
                                self.cardio = dayViewModel.days[dayNum-1].cardios[cardio.cardioNum-1]
                            }
                        }
                    }
                }
                Text("Time: ").padding(.top).frame(maxWidth: .infinity)
                Text("\(fixCardioTime(cardio: cardio))").font(.system(size: 75, weight: .bold))
            }.padding(.bottom)
            
            Divider()
            
            ScrollView
            {
                Text("\(cardio.instruction)")
            }
            Spacer()
        } .padding()
    }
}

struct AddWorkoutView : View
{
    @EnvironmentObject var dayViewModel: DayViewModel
    @Binding var addView : Bool
    @State var name = ""
    @State var type = workoutType.weightlift
    @State var instructions = ""
    @State var sets: Int?
    @State var reps: Int?
    @State var weight: Double?
    @State var hours: Int = 0
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var day: Day
    @State private var showInputAlert = false
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            Text("Add Workout").font(.system(size: 30, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            TextField("Enter workout name", text: $name)
            
            TextField("Enter workout instructions", text: $instructions)
            
            Picker("Type", selection: $type)
            {
                Text("Weight Lift").tag(workoutType.weightlift)
                Text("Cardio").tag(workoutType.cardio)
            }.pickerStyle(.segmented)
            
            if type == workoutType.weightlift {
                TextField("Enter sets", value: $sets, format: .number)
                TextField("Enter reps", value: $reps, format: .number)
                TextField("Enter weight", value: $weight, format: .number)
            }
            
            if type == workoutType.cardio {
                HStack {
                    Spacer()
                    Text("hour")
                    Text(":")
                    Text("min")
                    Text(":")
                    Text("sec")
                    Spacer()
                }
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .padding(.top, 25)
                HStack {
                    Spacer()
                    TextField("", value: $hours, format: .number)
                    Text(":")
                    TextField("", value: $minutes, format: .number)
                    Text(":")
                    TextField("", value: $seconds, format: .number)
                    Spacer()
                }
            }
            
            Button("Confirm"){
                if type == workoutType.weightlift {
                    dayViewModel.addWeightLift(instr: instructions, name: name, reps: reps ?? 0, sets: sets ?? 0, weight: weight ?? 0.0, dayNum: day.dayNum)
                }
                if type == workoutType.cardio {
                    dayViewModel.addCardio(instr: instructions, name: name, hours: hours, min: minutes, sec: seconds, dayNum: day.dayNum)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                {
                    reps = nil
                    sets = nil
                    weight = nil
                    hours = 0
                    minutes = 0
                    seconds = 0
                    addView = false;
                }
            }
            .buttonStyle(QuickFitButton()).frame(maxWidth: .infinity).padding()
            .alert("Input Type Error. Please Try Again", isPresented: $showInputAlert) {
                Button("OK", role: .cancel) { }
            }
            Spacer()
            
        }.padding().textFieldStyle(.roundedBorder)
    }
}
