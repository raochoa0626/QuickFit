//
//  Workout.swift
//  Project Draft
//
//  Created by Gene Sanmillan on 10/20/22.
//

import Foundation

// For determining calories per day
struct Day : Identifiable
{
    // Identifier (ie. Day 1, Day 2, Day 3...)
    var dayNum : Int
    
    // List of cardio
    var cardios : [Cardio]
    
    // List of lifts
    var lifts : [WeightLift]

    // Set of calories for the day
    var calories : Int
    
    // Date the day was added
    var date : String
    
    var id : String {
        String(dayNum)
    }
}

struct WeightLift: Identifiable {
    var liftNum: Int
    var name: String
    var instruction: String
    var weight: Double
    var sets: Int
    var reps: Int
    var setsFinished: Int = 0
    var id: String {
        String(liftNum)
    }
}

struct Cardio: Identifiable {
    var cardioNum: Int
    var name: String
    var instruction: String
    var hours: Int
    var minutes: Int
    var seconds: Int
    var id: String {
        String(cardioNum)
    }
}

enum workoutType
{
    case weightlift, cardio
}

struct Nutrition: Codable {
    let items: [Item]
}

// MARK: - Item
struct Item: Codable {
    let sugarG, fiberG: Double
    let servingSizeG, sodiumMg: Int
    let name: String
    let potassiumMg: Int
    let fatSaturatedG, fatTotalG, calories: Double
    let cholesterolMg: Int
    let proteinG, carbohydratesTotalG: Double

    enum CodingKeys: String, CodingKey {
        case sugarG = "sugar_g"
        case fiberG = "fiber_g"
        case servingSizeG = "serving_size_g"
        case sodiumMg = "sodium_mg"
        case name
        case potassiumMg = "potassium_mg"
        case fatSaturatedG = "fat_saturated_g"
        case fatTotalG = "fat_total_g"
        case calories
        case cholesterolMg = "cholesterol_mg"
        case proteinG = "protein_g"
        case carbohydratesTotalG = "carbohydrates_total_g"
    }
}

struct RecipeRecommendation : Identifiable
{
    let id = UUID()
    var recipes : [Recipe]
    var nutrition: Nutrition
}

struct Recipe: Identifiable, Codable{
    let id: Int
    let title: String
    let image: String
    let imageType: String
    let preparationMinutes: Int
    let cookingMinutes: Int
    let readyInMinutes: Int
    let sourceUrl: String
    let servings: Int
    let extendedIngredients: [Ingredient]
    let analyzedInstructions: [Instruction]
}

struct Response: Codable {
    let results: [Recipe]
    let offset: Int
    let number: Int
    let totalResults: Int
}

struct Ingredient: Codable, Hashable {
    let id: Int
    let name: String
    let original: String
    let amount: Double
    let unit: String
}

struct Instruction: Codable, Hashable {
    let steps: [Step]
}

struct Step: Codable, Hashable {
    let number: Int
    let step: String
}

// MARK: - WorkoutElement
struct WorkoutRecommendation : Identifiable {
    let id = UUID()
    var workouts : [Workout]
}

struct Workout: Codable, Hashable {
    let name: String
    let type: String
    let muscle: String
    let equipment: String
    let difficulty: String
    let instructions: String
}

struct MuscleGroup
{
    let muscleGroup = ["abdominals",
                          "abductors",
                          "adductors",
                          "biceps",
                          "calves",
                          "chest",
                          "forearms",
                          "glutes",
                          "hamstrings",
                          "lats",
                          "lowerback middleback",
                          "neck",
                          "quadriceps",
                          "traps",
                          "triceps"]
}

struct NutritionRecommendedList
{
    let list =
    [
        "Salad",
        "Healthy Snacks",
        "Tasty Veggies",
        "High Protein Meal"
    ]
}
