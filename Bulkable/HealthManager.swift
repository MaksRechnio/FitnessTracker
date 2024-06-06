//
//  HealthManager.swift
//  Bulkable
//
//  Created by Maksymilian Rechnio on 28/03/2024.
//

import SwiftUI
import HealthKit



extension Date {
    //Gives me the variable for the beginning of the current day - used in the functions to fetch day-apparent data
    static var startOfDay: Date{
        Calendar.current.startOfDay(for: Date())
    }
    
    //Developed this function with the use of chat GPT, by explaining and alternating the variable about (startOfDay)
    static var startOfWeek: Date {
           let calendar = Calendar.current
           let now = Date()
           let startOfDay = calendar.startOfDay(for: now)
           var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfDay)
           components.weekday = calendar.firstWeekday // Adjust to the calendar's first day of the week
           let startOfWeek = calendar.date(from: components)!
           return startOfWeek
       }
}

//I made this function with ChatGPT, because I do not have this knowledge
extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter() // Corrected initialization
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}


class HealthManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var activities: [String : Activity] = [:]
    
    @Published var mockActivities: [String : Activity] = [
        "todaySteps" : Activity(id: 0, title: "Daily Steps", subtitle: "Goal 10,000", image: "figure.walk", amount: "12,323"),
        "todayCalories" : Activity(id: 1, title: "Calories Burned", subtitle: "600", image: "flame.fill", amount: "120"),
        "Heart Rate" : Activity(id: 2, title: "Average Heart Rate", subtitle:  "BPM", image: "heart.fill", amount: "76")
        
    ]
    
    
    //Here I ask for permissions for the user data, which the user has to let me use.
    init() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let workout = HKObjectType.workoutType()
        let healthTypes: Set = [steps, calories, heartRateType, workout]
        
        
        //Error checking
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
                fetchHeartRate()
                fetchWeeklyRunningStats()
                fetchWeeklyStrength()
            } catch {
                print("Error fetching health data!")
            }
        }
    }
    
    
    //The first function created to develop an understanding of how to fetch fitness data in swift using the HealthKit
    //This function fetches the steps amount data for the day from the Healthkit
    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else {
                print("Error Fetching todays step data!")
                return
            }
            
            let stepCount = quantity.doubleValue(for: .count())
            let activity = Activity(id: 0, title: "Daily Steps", subtitle: "Goal 10,000", image: "figure.walk", amount: stepCount.formattedString())
            
            DispatchQueue.main.async {
                self.activities["todaySteps"] = activity
            }
        }
        healthStore.execute(query)
    }
    
    
    
    //This functions fetches calorie data (amount) from the apple watch (necessary for this to work) and displays it
    func fetchTodayCalories() {
        
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) {_, result, error in
            guard let quantity = result?.sumQuantity(), error == nil else{
                print("Error fetching todays calorie data!")
                return
            }
            let caloriesBurned = quantity.doubleValue(for: .kilocalorie())
            let activity = Activity(id: 1, title: "Calories Burned", subtitle: "600", image: "flame.fill", amount: caloriesBurned.formattedString())
            
            DispatchQueue.main.async {
                self.activities["caloriesBurned"] = activity
            }
        }
        healthStore.execute(query)
    }
    
    
    
    //This is the function that fetches data from the apple watch (necessary btw) and displays your average Heart rate for the day
    func fetchHeartRate() {
        
        // Define the heart rate quantity type.
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date(), options: .strictStartDate)
        
        // Create a statistics query to fetch the average heart rate.
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: [.discreteAverage]) { _, result, error in
            guard let quantity = result?.averageQuantity(), error == nil else {
                print("Error fetching today's heart rate data!")
                return
            }
            // Convert the heart rate to beats per minute.
            let heartRateBPM = quantity.doubleValue(for: HKUnit(from: "count/min"))
            
            // Convert the heart rate BPM to a string for the Activity initializer.
            let heartRateString = String(format: "%.0f", heartRateBPM) // Rounds the heart rate to the nearest whole number and converts it to a string.
            
            let activity = Activity(id: 2, title: "Average Heart Rate", subtitle: "\(Int(heartRateBPM)) BPM", image: "heart.fill", amount: heartRateString)
            
            DispatchQueue.main.async {
                self.activities["heartRate"] = activity
            }
        }
        
        healthStore.execute(query)
    }

    
    
    
    
    //This funtion will fetch information about the specific workouts done by the user, from the workouts available in the Health kit - made 03.04.2024
    func fetchWeeklyRunningStats() {
        
        let workout = HKSampleType.workoutType()
        
        //We need three predicates here actually as one is for the period that it covers, second for the type of the workout and third to define the workout.
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date(), options: .strictStartDate)
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .running)
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [timePredicate, workoutPredicate])
        
        let query = HKSampleQuery(sampleType: workout, predicate: predicate, limit: 20, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("Error fetching week's running data!")
                return
            }
            
            var count: Int = 0
            for workout in workouts {
                let duration = Int(workout.duration)/60
                count += duration
            }
            
            let activity = Activity(id: 3, title: "Running", subtitle: "This Week", image: "figure.run.circle", amount: "\(count) minutes")
            
            DispatchQueue.main.async {
                self.activities["weekRunning"] = activity
            }
        }
        healthStore.execute(query)
        
    }
    
    //This funtion will fetch information about the specific workouts done by the user, from the workouts available in the Health kit - made 03.04.2024
    func fetchWeeklyStrength() {
        
        let workout = HKSampleType.workoutType()
        
        //We need three predicates here actually as one is for the period that it covers, second for the type of the workout and third to define the workout.
        let timePredicate = HKQuery.predicateForSamples(withStart: .startOfWeek, end: Date(), options: .strictStartDate)
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .traditionalStrengthTraining)
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [timePredicate, workoutPredicate])
        
        let query = HKSampleQuery(sampleType: workout, predicate: predicate, limit: 20, sortDescriptors: nil) { _, sample, error in
            guard let workouts = sample as? [HKWorkout], error == nil else {
                print("Error fetching week's running data!")
                return
            }
            
            var count: Int = 0
            for workout in workouts {
                let duration = Int(workout.duration)/60
                count += duration
            }
            
            let activity = Activity(id: 4, title: "Weight Lifting", subtitle: "This Week", image: "dumbbell", amount: "\(count) minutes")
            
            DispatchQueue.main.async {
                self.activities["weekStrength"] = activity
            }
        }
        healthStore.execute(query)
        
    }


}



