//
//  NutritionView.swift
//  Project Draft
//
//  Created by Gene Sanmillan on 10/23/22.
//

import SwiftUI
import SwiftUICharts

struct MainNutritionView : View
{
    @EnvironmentObject var dayViewModel: DayViewModel
    
    var body: some View
    {
        NavigationStack
        {
            VStack
            {
                LineChartView(data: dayViewModel.getWeeklyNutritionChart(), title: "Calories Analysis", form: ChartForm.extraLarge, rateValue: dayViewModel.getNutritionRate()).padding()

                
                List
                {
                    ForEach(dayViewModel.days.reversed())
                    {
                        day in

                        NavigationLink(
                            destination: AddCaloriesView(day: day),
                            label:
                            {
                                VStack(alignment: .leading)
                                {

                                    Text("\(getDayDate(day: day.date))").bold()
                                    Text("\(day.calories) calories")
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
            .toolbar
            {
                ToolbarItem(placement: .principal)
                {
                    HStack
                    {
                        Text("Nutrition").font(.system(size: 25, weight: .bold))

                        Spacer()

                        // Add Button
                        Button
                        {
                            dayViewModel.addDay()
                        } label:
                        {
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

struct AddCaloriesView : View
{
    @EnvironmentObject var dayViewModel: DayViewModel
    @State var day : Day
    @State var editCalories = false
    @State var addCalories = false
    @State var calories = ""
    
    var body: some View
    {
        VStack
        {
            Spacer()
            
            Text(String(day.date.prefix(12)))
            
            Text("\(day.calories)").font(.system(size: 75, weight: .bold))
            
            Text("calories").padding(.bottom)
            
            
            HStack{
                Button
                {
                    addCalories = true
                    calories = ""
                }
                label:
                {
                    Label("Add Calories", systemImage: "plus")
                }.buttonStyle(.bordered)
                .alert("Add Calories", isPresented: $addCalories, actions:
                        {
                    TextField("Enter calories to add", text: $calories)
                    
                    Button("Cancel"){}.keyboardShortcut(.defaultAction)
                    Button("Confirm")
                    {
                        if let newCalories = Int(calories)
                        {
                            dayViewModel.setCalories(cal: day.calories + newCalories, dayN: day.dayNum)
                            day.calories = day.calories + newCalories
                        }
                    }
                    
                })
                
                Spacer()
                
                Button
                {
                    editCalories = true
                    calories = "\(day.calories)"
                }
                label:
                {
                    Label("Edit calories", systemImage: "pencil")
                }.buttonStyle(.bordered)
                .alert("Edit calories", isPresented: $editCalories, actions:
                        {
                    TextField("Enter calories", text: $calories)
                    
                    Button("Cancel"){}.keyboardShortcut(.defaultAction)
                    Button("Confirm")
                    {
                        if let newCalories = Int(calories)
                        {
                            dayViewModel.setCalories(cal: newCalories, dayN: day.dayNum)
                            day.calories = newCalories
                        }
                    }
                    
                })
            }.padding(.horizontal)
            
            Spacer()
            Spacer()
        }.padding()
    }
}
