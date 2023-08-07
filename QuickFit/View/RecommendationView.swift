//
//  RecommendationView.swift
//  QuickFit
//
//  Created by Gene Sanmillan on 11/27/22.
//

import SwiftUI

struct MainRecommendationView : View
{
    @StateObject var dayViewModel : DayViewModel
    @StateObject private var nutsViewModel = NutritionApiViewModel()
    @StateObject private var workoutViewModel = WorkoutApiViewModel()
    @State private var recommendationView = recommendationMenu.workout
    @State private var searchText = ""
    @State private var defaultSearchText = "Muscle group"
    
    enum recommendationMenu
    {
        case workout, nutrition
    }
    
    var body: some View
    {
        NavigationStack
        {
            VStack
            {
                Picker("View", selection: $recommendationView)
                {
                    Text("Workout").tag(recommendationMenu.workout)
                    Text("Nutrition").tag(recommendationMenu.nutrition)
                }.pickerStyle(.segmented).onChange(of: recommendationView, perform:
                { _ in
                    searchText = ""
                    
                    if(recommendationView == recommendationMenu.workout)
                    {
                        defaultSearchText = "Muscle group"
                        workoutViewModel.workoutRec.workouts = []
                    }
                    else
                    {
                        defaultSearchText = "Food"
                        nutsViewModel.recommendations = RecipeRecommendation(recipes: [], nutrition: Nutrition(items: []))
                        
                    }
                })
                
                HStack{
                    TextField(defaultSearchText, text: $searchText).textFieldStyle(.roundedBorder)
                        .onChange(of: searchText, perform:
                        { _ in
                            if(searchText == "")
                            {
                                nutsViewModel.recommendations = RecipeRecommendation(recipes: [], nutrition: Nutrition(items: []))
                                workoutViewModel.workoutRec.workouts = []
                            }
                        })
                    
                    Button(action: {
                        if(recommendationView == recommendationMenu.nutrition){
                            nutsViewModel.fetchNutrition(search: searchText)
                            nutsViewModel.fetchRecipe(search: searchText)
                        }
                        else
                        {
                            workoutViewModel.fetchData(search: searchText)
                        }
                    }){
                        Text("Search").padding()
                    }
                    .buttonStyle(QuickFitRecButton())
                }
                
                if(recommendationView == recommendationMenu.workout)
                {
                    WorkoutRecommendationView(workoutViewModel: workoutViewModel, searchText: $searchText)
                }
                else
                {
                    RecipeRecommendationView(nutsViewModel: nutsViewModel, dayViewModel: dayViewModel, searchText: $searchText)
                }
                
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement: .principal)
                {
                    HStack
                    {
                        Text("Recommendation").font(.system(size: 25, weight: .bold))

                        Spacer()
                        
                    } // End of HStack
                }
            } // End of .toolbar | VStack
        } // End of NavigationStack
    }
}

struct RecipeRecommendationView : View
{
    @StateObject var nutsViewModel : NutritionApiViewModel
    @StateObject var dayViewModel : DayViewModel
    @Binding var searchText : String
    
    var body: some View
    {
        if(nutsViewModel.recommendations.recipes.count == 0 && searchText == "")
        {
            VStack(alignment: .leading)
            {
                Text("Examples: ")
            }
        }
        
        List
        {
            if(nutsViewModel.recommendations.recipes.count == 0 && searchText == "")
            {
                ForEach(NutritionRecommendedList().list, id: \.self)
                {
                    name in
                    Button
                    {
                        searchText = name
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            nutsViewModel.fetchNutrition(search: searchText)
                            nutsViewModel.fetchRecipe(search: searchText)
                        }
                    }
                    label:
                    {
                        VStack(alignment: .leading)
                        {
                            Text(name.capitalized)
                        }
                        
                    }
                }
            }
            
            if(!nutsViewModel.recommendations.nutrition.items.isEmpty)
            {
                VStack(alignment: .leading)
                {
                    Text("Estimated Nutritional facts: ").bold()
                    Text("Name: \(nutsViewModel.recommendations.nutrition.items[0].name)")
                    Text("Calories: \(nutsViewModel.recommendations.nutrition.items[0].calories, specifier: "%.2f")")
                    Text("Protein: \(nutsViewModel.recommendations.nutrition.items[0].proteinG, specifier: "%.2f")g")
                    Text("Serving Size: \(nutsViewModel.recommendations.nutrition.items[0].servingSizeG)g")
                    Text("Sugar: \(nutsViewModel.recommendations.nutrition.items[0].sugarG, specifier: "%.2f")g")
                    Text("Fat Total: \(nutsViewModel.recommendations.nutrition.items[0].fatTotalG, specifier: "%.2f")g")
                    Text("Fat Saturated: \(nutsViewModel.recommendations.nutrition.items[0].fatSaturatedG, specifier: "%.2f")g")
                }
            }

            ForEach(nutsViewModel.recommendations.recipes)
            {
                recipe in
                NavigationLink(destination: RecipeView(recipe: recipe),
                label: { RecipeLabel(recipe: recipe)})
            }
        }
        .background(Color(UIColor.systemBackground))
        .scrollContentBackground(.hidden)
        .listStyle(PlainListStyle())
    }
}

struct RecipeLabel : View
{
    var recipe : Recipe
    
    var body: some View
    {
        HStack{
            AsyncImage(url: URL(string: recipe.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 70)
                    .cornerRadius(10)
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading)
            {
                Text(recipe.title).bold()
                Text("Ready in: \(recipe.readyInMinutes) Minutes").foregroundColor(.secondary)
            }
            
            Spacer()
            
        }
    }
}

struct RecipeView : View
{
    var recipe : Recipe
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(alignment: .leading)
            {
                Text("\(recipe.title)").font(.system(size: 30)).bold().frame(maxWidth: .infinity, alignment: .leading)
                Text("Ready In: \(recipe.readyInMinutes)").foregroundColor(.secondary)
                Text("Servings: \(recipe.servings)").foregroundColor(.secondary)
                
                AsyncImage(url: URL(string: recipe.image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        EmptyView()
                    }
                }
                
                Divider()
                
                VStack(alignment: .leading)
                {
                    Text("Ingredients: ").bold().font(.system(size: 20)).padding(.vertical)
                    ForEach(recipe.extendedIngredients, id: \.self)
                    {
                        ingredient in
                        Text("\(ingredient.original)")
                    }
                    
                    Divider()
                    
                    Text("Instructions: ").bold().font(.system(size: 20))
                    
                    Divider()
                    
                    ForEach(recipe.analyzedInstructions, id: \.self)
                    {
                        instruction in
                        ForEach(instruction.steps, id: \.self)
                        {
                            step in
                            VStack(alignment: .leading)
                            {
                                Text("Step \(step.number)").bold()
                                Text("\(step.step)")
                                Divider()
                            }
                        }
                    }
                }
                
                Spacer()
            }.padding()
        }
    }
}

struct WorkoutRecommendationView : View
{
    @StateObject var workoutViewModel : WorkoutApiViewModel
    @Binding var searchText : String
    var body: some View
    {
        if(workoutViewModel.workoutRec.workouts.count == 0 && searchText == "")
        {
            VStack(alignment: .leading)
            {
                Text("Muscle group options: ")
            }
        }
        
        List
        {
            if(workoutViewModel.workoutRec.workouts.count == 0 && searchText == "")
            {
                ForEach(MuscleGroup().muscleGroup, id: \.self)
                {
                    group in
                    Button
                    {
                        searchText = group
                        workoutViewModel.fetchData(search: searchText)
                    }
                    label:
                    {
                        VStack(alignment: .leading)
                        {
                            Text(group.capitalized)
                        }
                        
                    }
                }
            }
            
            
            ForEach(workoutViewModel.workoutRec.workouts, id: \.self)
            {
                workout in
                NavigationLink(destination: WorkoutRecDetailsView(workout: workout),
                label:
                {
                    
                    VStack(alignment: .leading)
                    {
                        Text("\(workout.name.capitalized)").bold()
                        Text("\(workout.difficulty.capitalized)").foregroundColor(.secondary)
                    }
                })
            }
        }
        .background(Color(UIColor.systemBackground))
        .scrollContentBackground(.hidden)
        .listStyle(PlainListStyle())
        .accentColor(.primary)
    }
}

struct WorkoutRecDetailsView : View
{
    @State var workout : Workout
    var body: some View
    {
        ScrollView(.vertical)
        {
            VStack(alignment: .leading)
            {
                Text("\(workout.name)").font(.system(size: 30)).bold().frame(maxWidth: .infinity, alignment: .leading)
                Text("\(workout.muscle.capitalized)").foregroundColor(.secondary)
                
                Divider()
                
                Text("Difficulty: \(workout.difficulty.capitalized)")
                Text("Equipment: \(workout.equipment.capitalized)")
                Text("Type: \(workout.type.capitalized)")
                
                Divider()
                
                Text("Instructions: ").bold().font(.system(size: 20)).padding(.bottom, -3)
                Text("\(workout.instructions)")
                
                WorkoutRecDetailsButtonView(workout: $workout)
                
            }.padding()
        }
    }
}

struct WorkoutRecDetailsButtonView : View {
    
    @EnvironmentObject var dayViewModel: DayViewModel
    @Binding var workout : Workout
    @State var addView = false
    
    var body: some View
    {
        Divider()
        
        HStack {
            Spacer()
            Button {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
                {
                    addView = true
                }
            } label: {
                HStack {
                    Text("Add")
                    Text("\(workout.name)").bold()
                    Text("to current day")
                }
            }
            .buttonStyle(QuickFitButton())
            .sheet(isPresented: $addView) { AddWorkoutWithRecView(addView: $addView, name: workout.name, instructions: workout.instructions) }
            Spacer()
        }
        .padding(.top, 10)
    }
}

struct AddWorkoutWithRecView : View
{
    @EnvironmentObject var dayViewModel: DayViewModel
    
    @Binding var addView: Bool
    @State var name: String
    @State var instructions: String
    
    @State var sets: Int?
    @State var reps: Int?
    @State var weight: Double?
    
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 15)
        {
            Text("Add Workout").font(.system(size: 30, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            TextField("Enter workout name", text: $name)
            TextField("Enter workout instructions", text: $instructions)
            
            Divider().padding(.vertical)
            
            TextField("Enter sets", value: $sets, format: .number)
            TextField("Enter reps", value: $reps, format: .number)
            TextField("Enter weight", value: $weight, format: .number)
            
            Button("Confirm"){
                dayViewModel.addWeightLiftToLatestDay(instr: instructions, name: name, reps: reps ?? 0, sets: sets ?? 0, weight: weight ?? 0.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
                {
                    reps = nil
                    sets = nil
                    weight = nil
                    addView = false;
                }
            }
            .buttonStyle(QuickFitButton()).frame(maxWidth: .infinity).padding()
            Spacer()
            
        }.padding().textFieldStyle(.roundedBorder)
    }
}
