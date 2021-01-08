//
//  ContentView.swift
//  BetterRest
//
//  Created by Arnab Sudeshna on 11/24/20.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeupTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView{
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you want to wake up?").font(.headline).foregroundColor(.blue)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden().datePickerStyle(WheelDatePickerStyle())
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amout of sleep").font(.headline).foregroundColor(.blue)
                    Stepper(value:$sleepAmount, in: 4...12, step: 0.25){
                        Text("\(sleepAmount ,specifier: "%g") Hours").padding()
                    }
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake").font(.headline).foregroundColor(.blue)
                    
                    Stepper(value: $coffeeAmount, in: 1...10){
                        if coffeeAmount == 1{
                            Text("1 cup").padding()
                        } else {
                            Text("\(coffeeAmount) cup").padding()
                        }
                    }
                }
                
            }.navigationBarTitle("Better Rest")
            .navigationBarItems(trailing:
                                    Button(action: calculateBedtime) {
                                            Text("Calculate")
                                    }.padding()
            ) .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMsg), dismissButton: .default(Text("OK")))
            }
        }
        
    }
    
   //we can make defaultWakeTime a static variable, which means it belongs to the ContentView struct itself rather than a single instance of that struct. This in turn means defaultWakeTime can be read whenever we want, because it doesn’t rely on the existence of any other properties.
    
    static var defaultWakeupTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func calculateBedtime(){
        
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60 * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleeptime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short

            alertMsg = formatter.string(from: sleeptime)
            alertTitle = "Your ideal bedtime is…"
            
        } catch  {
            alertTitle = "Error"
            alertMsg = "Sorry, something went wrong"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

