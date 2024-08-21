//
//  MapScreen.swift
//  Workout Detail
//
//  Created by Marina Huber on 01.10.2021..
//

// NOT USED!

import Foundation
import MapKit
import SwiftUI
import UIKit
import StoreKit

@available(iOS 14.0, *)
struct MapScreen: View {
    
    @StateObject var workoutProvider: WorkoutProvider
    
    @State var mapType = 1
    @State var showShareModalView: Bool = false
    @State var showingGraphs = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
            ZStack {            
                MapViewRepresentable(workoutProvider: workoutProvider)
                    .edgesIgnoringSafeArea(.all)
                
                GradientView()
                    .cornerRadius(12)
                    .padding()
                    .offset(x: 0, y: 330)
                VStack {
                    
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        })
                        {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                        }
                        
                        .padding()
                        .foregroundColor(Color.white)
                        
                        Divider()
                        Picker("", selection: $mapType)
                        {
                            Text("Plain").tag(0)
                            Text("Satelitte").tag(1)
                                .background(Color.orange)
                        }
                        .pickerStyle(.segmented)
                        .padding(CGFloat(30))
                        .offset(x: -50, y: 0)
                        .onAppear {
                            UISegmentedControl.appearance().backgroundColor = .systemGray6
                        }
                        Divider()
                        Menu {
                            //Always Shown
                            Button(action: {
                                showShareModalView = true
                            }, label:  {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable().frame(width: 25, height: 25)
                                Text("Share")
                            })
                            //Always Shown
                            Button(action: {
                            }) {
                                Text("Splits").foregroundColor(Color(UIColor.purple))
                                    .font(.headline)
                                Image(uiImage: UIImage(named: "split_marker") ?? UIImage())
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            //If Pro
                                Button(action: {
                                    //hide race annotation
                                }) {
                                    Text("Race")
                                    Image(uiImage: UIImage(named: "flag.circle") ?? UIImage())
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    
                                }
                            //If Pro and added by user
                                Button(action: {
                                    //hide markers annotation
                                }) {
                                    Text("Markers")
                                    Image(uiImage: UIImage(named: "mappin.circle") ?? UIImage())
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                    
                                }
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title)
                            
                        }
                        .padding()
                        .foregroundColor(Color.white)
          
                    }
                    Spacer()
                    Spacer()
                    graphButton
                    .offset(x: 150, y: 220)
                    
                }
                .padding()
                .offset(x: 0, y: -300)
                .fullScreenCover(isPresented: $showShareModalView) {
                }

            }
        }
    
    var graphButton: some View {
      Button(action: { self.showingGraphs.toggle() }) {
        Image(systemName: "chart.xyaxis.line")
          .mapButtonImageStyle()
          .accessibility(label: Text("Graphs"))
      }
      .padding(5)
      .hoverEffect()
      .sheet(isPresented: $showingGraphs) {
          //  GraphsMain()
          //.navigationViewStyle(StackNavigationViewStyle())
      }
    }
    
    
}

struct GradientView: View {
    
    var body: some View {
        Text("Speed")
            .frame(width: 330, height: 30)
            .foregroundColor(.white)
            .font(.title3)
            .background(
                LinearGradient(gradient: Gradient(colors: [.green, .yellow, .orange, .red]), startPoint: .leading, endPoint: .trailing)
            )
    }
}
