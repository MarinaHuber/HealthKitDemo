//
//  Image+Extention.swift
//  Workout Detail
//
//  Created by Marina Huber on 07.10.2021..
//

import SwiftUI

extension Image {

  func mapButtonImageStyle() -> some View {
    self
      .imageScale(.large)
      .frame(minWidth: 50, minHeight: 50)
      .background(Color.white)
      .cornerRadius(28)
      .shadow(color: Color.black, radius: 5)
  }

}
