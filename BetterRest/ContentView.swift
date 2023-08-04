//
//  ContentView.swift
//  BetterRest
//
//  Created by Maverick Brazill on 7/24/23.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State var wakeup = Date.now
    @State var wantedSleepHRs = 9
    @State var cupsOfCoffeePerDay = 1
    
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showAlert = false
    
    func calculate(){
        do{
            let model = try SleepCalculator(configuration: .init())
            
            let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeup)
            let hour = (dateComponents.hour ?? 0) * 60 * 60
            let minute = (dateComponents.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: Double(wantedSleepHRs), coffee: Double(cupsOfCoffeePerDay))
            
            let output = wakeup - prediction.actualSleep
            
            alertTitle = "Ideal Bedtime"
            alertMessage = output.formatted(date: .omitted, time: .shortened)
            showAlert = true
        }catch{
            alertTitle = "Oop"
            alertMessage = "There was an error calculating your bedtime."
            showAlert = true
        }
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                Form{
                    DatePicker("Desired Wakeup Time:", selection: $wakeup, displayedComponents: .hourAndMinute)
                    Stepper("Desired Hours of \nSleep per night: **\(wantedSleepHRs)**", value: $wantedSleepHRs, in: 5...12)
                    Stepper("Cups of Coffee\nDrank per day: **\(cupsOfCoffeePerDay)**", value: $cupsOfCoffeePerDay, in: 1...20)
                }
            }.alert(alertTitle, isPresented: $showAlert){
                Button{}label:{
                    Text("Dismiss")
                }
            } message: { Text(alertMessage) }
            
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button{ calculate() }label:{
                        Text("Calculate")
                    }.buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
