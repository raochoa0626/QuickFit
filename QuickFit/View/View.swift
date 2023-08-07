//
//  View.swift
//  Project Draft
//
//  Created by Gene Sanmillan on 10/20/22.
//

import SwiftUI
import Charts
import SwiftUICharts
struct MainView : View
{
    @StateObject private var viewModel = DayViewModel()
    
    var body: some View
    {
        TabView
        {
            MainWorkoutView().tabItem
            {
                Image(systemName: "figure.walk")
                Text("Workout")
            }
            
            MainNutritionView().tabItem
            {
                Image(systemName: "suit.heart.fill")
                Text("Nutrition")
            }
            
            MainRecommendationView(dayViewModel: viewModel).tabItem
            {
                Image(systemName: "magnifyingglass")
                Text("Recommendation")
            }

        }.accentColor(QFButtonColor.customBlue)
    }
}

struct QuickFitButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .padding(.horizontal, 15)
            .background(QFButtonColor.customBlue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct QuickFitPlusButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.leading, 10)
            .padding(.trailing, 15)
            .background(QFButtonColor.customBlue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct QuickFitDeleteButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(.red)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct QuickFitRecButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, -7)
            .padding(.horizontal, 1)
            .background(QFButtonColor.customBlue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct QFButtonColor {
    static let customBlue = Color("QFButtonColor")
}
