//
//  CrashTestView.swift
//  SwarmfarmUI
//
//  Created by Swarmfarm on 28/2/20.
//  Copyright © 2020 Swarmfarm. All rights reserved.
//

import SwiftUI
import Combine

let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
func randomString(length: Int) -> String {
    return String((0..<length).map { _ in letters.randomElement()! })
}

var lastlhs: [CrashTestModel.ListElement] = []
var lastrhs: [CrashTestModel.ListElement] = []

class CrashTestModel: ObservableObject
{
    struct ListElement: Equatable, Identifiable
    {
        var id: String { title }
        
        var title: String
        var toggle: Bool
                
        init(title: String, toggle: Bool)
        {
            self.title = title
            self.toggle = toggle
        }
        
        static func == (lhs: CrashTestModel.ListElement, rhs: CrashTestModel.ListElement) -> Bool {
            return lhs.title == rhs.title && lhs.toggle == rhs.toggle
        }
    }

    @Published var lhsElems: [ListElement] = []
    
    @Published var rhsElems: [ListElement] = []
    
    @Published var showRhsElems: Bool = false
    
    var timer = Timer.TimerPublisher(interval: 0.1, runLoop: .main, mode: .default).autoconnect()
    
    var cancellable: AnyCancellable? = nil
    
    init()
    {
        cancellable = timer
        .sink { [weak self] _ in
            var newLhsElems: [ListElement] = []
            for _ in 0..<Int.random(in: 0..<50)
            {
                newLhsElems.append(ListElement(title: randomString(length: Int.random(in: 0..<20)), toggle: Bool.random()))
            }
            CrashTestModel.duplicateRandom(&newLhsElems)
            CrashTestModel.injectCommon(&newLhsElems)

            var newRhsElems: [ListElement] = []
            for _ in 0..<Int.random(in: 0..<50)
            {
                newRhsElems.append(ListElement(title: randomString(length: Int.random(in: 0..<20)), toggle: Bool.random()))
            }
            CrashTestModel.duplicateRandom(&newRhsElems)
            CrashTestModel.injectCommon(&newRhsElems)

            lastlhs = newLhsElems
            lastrhs = newRhsElems
            
            withAnimation(.easeInOut(duration: 0.2)) { [weak self] in
                self?.lhsElems = newLhsElems
            }
            
            withAnimation(.easeInOut(duration: 0.5)) { [weak self] in
                self?.rhsElems = newRhsElems
            }

            withAnimation(.easeInOut(duration: 1.0)) { [weak self] in
                self?.showRhsElems = Bool.random()
            }
        }
    }
    
    static func duplicateRandom(_ elems: inout [ListElement])
    {
        if Int.random(in: 0..<5) == 3
        {
            let fencepost = elems.count - 1
            if fencepost > 0
            {
                let index = Int.random(in: 0...fencepost)
                let elem = elems[index]
                elems[min(Int.random(in: 0..<9), fencepost)] = elem
                
                let backwards = fencepost - Int.random(in: 0..<9)
                if backwards > 0
                {
                    elems[backwards] = elem
                }
            }
        }
    }
    
    static var commonVar: ListElement = ListElement(title: "I AM A COMMON ELEMENT", toggle: true)
    
    static func injectCommon(_ elems: inout [ListElement])
    {
        let start = 5
        let end = elems.count - start
        var index = Int.random(in: end..<elems.count)
        
        if index >= 0 && index < elems.count
        {
            elems[index] = commonVar
            index += 1
            if index >= 0 && index < elems.count
            {
                elems[index] = commonVar
            }
        }
    }

}

var globalModel: CrashTestModel = CrashTestModel()

struct CrashTestView: View
{
    @ObservedObject var model = globalModel
    
    var lhs: some View {
        List(model.lhsElems) { elem in
            HStack {
                Text(elem.title)
                Spacer()
                Image(systemName: elem.toggle ? "plus" : "checkmark")
            }
        }
        .transition(.move(edge: .leading))
    }
    
    var rhs: some View {
        List(model.rhsElems) { elem in
            HStack {
                Text(elem.title)
                Spacer()
                Image(systemName: elem.toggle ? "plus" : "checkmark")
            }
        }
        .transition(.move(edge: .trailing))
    }
    
    var body: some View
    {
        ViewBuilder.buildBlock(
            model.showRhsElems
            ? ViewBuilder.buildEither(first: rhs)
            : ViewBuilder.buildEither(second: lhs)
        )
        .overlay(Color(model.showRhsElems ? .systemPink : .systemTeal).opacity(0.1))
    }
}
