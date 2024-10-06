//
//  ContentView.swift
//  SwipeLess
//
//  Created by Vedansh Surjan on 06/10/24.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var caloriesBurned: Double = 0.0
    private var healthStore = HKHealthStore()
    
    var body: some View {
        VStack {
            Text("Calories Burned")
                .font(.largeTitle)
                .padding()
            
            Text("\(caloriesBurned, specifier: "%.2f") kcal")
                .font(.title)
                .padding()
            
            Button(action: {
                requestAuthorization()
            }) {
                Text("Refresh Calories")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    func requestAuthorization() {
        let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let typesToRead: Set = [energyType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                fetchCaloriesBurned()
            } else {
                print("Authorization failed: \(String(describing: error))")
            }
        }
    }
    
    func fetchCaloriesBurned() {
        let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                return
            }
            self.caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())
        }
        
        healthStore.execute(query)
    }
    
    //    func fetchInstagramUsage() {
    //           // Simulate fetching usage data
    //           // In a real app, guide users to check Screen Time settings
    //           instagramUsageTime = "30 minutes" // Simulated data
    //       }
}

#Preview {
    ContentView()
}
