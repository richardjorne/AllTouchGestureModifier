//
//  AllTouchGestureModifier.swift
//  AllTouchGestureModifier
//
//  Created by Richard Jorne on 2024/7/16.
//


import SwiftUI

public enum TouchState: Int, Hashable, Equatable {
    /// The state when the user begins to touch the view.
    case touchDown = 0
    /// The state when the user releases the touch inside the view.
    case confirm = 1
    /// The state when the user releases the touch, regardless of the position.
    case touchUp = 2
    /// The state when the user releases the touch outside the view, typically because the user dragged outside the view and released.
    case cancel = -1
    /// The state when the user is dragging.
    case dragging = 3
    /// The state when the user is dragging inside the view.
    case dragInside = 4
    /// The state when the user is dragging outside the view.
    case dragOutside = -2
    /// The state when the user has dragged outside the view and is now dragging back inside.
    case dragEnter = 5
    /// The state when the user has dragged inside the view and is now dragging outside.
    case dragExit = -3
}


public struct AllTouchGestureModifier: ViewModifier {
    
    public let onTouchDown: (CGPoint, CGSize) -> Void
    public let onConfirm: (CGPoint, CGSize) -> Void
    public let onTouchUp: (CGPoint, CGSize) -> Void
    public let onCancel: (CGPoint, CGSize) -> Void
    public let onDragging: (CGPoint, CGSize) -> Void
    public let onDragInside: (CGPoint, CGSize) -> Void
    public let onDragOutside: (CGPoint, CGSize) -> Void
    public let onDragEnter: (CGPoint, CGSize) -> Void
    public let onDragExit: (CGPoint, CGSize) -> Void
    
    @State private var isDragging = false
    @State private var dragLocation: CGPoint = .zero
    @State private var geo: GeometryProxy?
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            self.geo = geo
                        }
                }
            )
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if let geo = geo {
                        if !isDragging {
                            if !isPointInside(value.location, in: geo) { return; }
                            isDragging = true
                            onTouchDown(value.location, geo.size)
                        }
                        if isPointInside(value.location, in: geo) {
                            onDragInside(value.location, geo.size)
                            if !isPointInside(dragLocation, in: geo) {
                                onDragEnter(value.location, geo.size)
                            }
                        } else {
                            onDragOutside(value.location, geo.size)
                            if isPointInside(dragLocation, in: geo) {
                                onDragExit(value.location, geo.size)
                            }
                        }
                        onDragging(value.location, geo.size)
                        dragLocation = value.location
                    }
                }
                .onEnded { value in
                    isDragging = false
                    if let geo = geo {
                        onTouchUp(dragLocation, geo.size)
                        if isPointInside(value.location, in: geo) {
                            onConfirm(value.location, geo.size)
                        } else {
                            onCancel(value.location, geo.size)
                        }
                    }
                    dragLocation = value.location
                }
            )
    }
    
    private func isPointInside(_ point: CGPoint, in geometry: GeometryProxy) -> Bool {
        let localBounds = CGRect(origin: .zero, size: geometry.size)
        return localBounds.contains(point)
    }
}


// MARK: - AllTouchGesture View Extension
extension View {
    /// A view modifier that adds a comprehensive touch gesture handling to a view.
    ///
    /// This modifier allows you to respond to various touch events. Each event is represented by a separate closure with position so that you can provide to handle the corresponding touch state and access the position of touch.
    ///
    ///   - Warning: `onDragging`, `onDragOutside` and `onDragInside` can be frequently called, while `onTouchDown`, `onConfirm`, `onTouchUp`, `onCancel` are always called once each full interaction.
    ///
    /// - Parameters:
    ///   - onTouchDown: Executed when the user begins to touch the view (`touchDown`).
    ///   - onConfirm: Executed when the user releases the touch inside the view (`confirm`).
    ///   - onTouchUp: Executed when the user releases the touch, regardless of position (`touchUp`).
    ///   - onCancel: Executed when the user releases the touch outside the view (`cancel`).
    ///   - onDragging: Executed whenever the user is actively dragging within the view (`dragging`).
    ///   - onDragInside: Executed whenever the user is actively dragging inside the view (`dragInside`).
    ///   - onDragOutside: Executed whenever the user is actively dragging outside the view (`dragOutside`).
    ///   - onDragEnter: Executed when the user, after dragging outside, re-enters the view area (`dragEnter`).
    ///   - onDragExit: Executed when the user drags out of the view area after being inside (`dragExit`).
    public func allTouchGesture(
        onTouchDown: @escaping (CGPoint, CGSize) -> Void = { _, _ in },
        onConfirm: @escaping (CGPoint, CGSize) -> Void = { _, _ in },
        onTouchUp: @escaping (CGPoint, CGSize) -> Void = { _, _ in },
        onCancel: @escaping (CGPoint, CGSize) -> Void = { _, _ in },
        onDragging: @escaping (CGPoint, CGSize) -> Void = { _, _ in },
        onDragInside: @escaping (CGPoint, CGSize) -> Void = { _, _ in },
        onDragOutside: @escaping (CGPoint, CGSize) -> Void = { _, _ in },
        onDragEnter: @escaping (CGPoint, CGSize) -> Void = { _, _ in },
        onDragExit: @escaping (CGPoint, CGSize) -> Void = { _, _ in }
    ) -> some View {
        self.modifier(AllTouchGestureModifier(
            onTouchDown: onTouchDown,
            onConfirm: onConfirm,
            onTouchUp: onTouchUp,
            onCancel: onCancel,
            onDragging: onDragging,
            onDragInside: onDragInside,
            onDragOutside: onDragOutside,
            onDragEnter: onDragEnter,
            onDragExit: onDragExit
        ))
    }
}

fileprivate struct AllTouchGesturePreview: View {
    
    @State private var pos: CGPoint = .zero
    @State private var states: [TouchState] = [.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp]
    
    var body: some View {
        VStack {
            ZStack {
                LinearGradient(colors: [Color(red: 52/255, green: 152/255, blue: 219/255), .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .cornerRadius(15)
                    .frame(width: 300, height: 160)                    
                VStack {
                    Text("AllTouchGestureModifier")
                    Text(stateText(states.last ?? .touchUp))
                    Text("\(String(format: "%.2f", pos.x)), \(String(format: "%.2f", pos.y))")
                }
                .font(.system(size: 20, weight: .bold))
            }
            .allTouchGesture { pos, size in
                states.removeFirst()
                self.pos = pos
                self.states.append(.touchDown)
            } onConfirm: { pos, size in
                states.removeFirst()
                self.pos = pos
                self.states.append(.confirm)
            } onTouchUp: { pos, size in
                states.removeFirst()
                self.pos = pos
                self.states.append(.touchUp)
            } onCancel: { pos, size in
                states.removeFirst()
                self.pos = pos
                self.states.append(.cancel)
            }
        // Notice how multiple allTouchGesture's behavior can be cumulated.
            .allTouchGesture{_, _ in } onDragging: { pos, size in
                self.pos = pos
                //                        states.removeFirst()
                //                        self.states.append(.dragging)
            } onDragInside: { pos, size in
                // Uncomment to try it out!
                //                        states.removeFirst()
                //                        self.pos = pos
                //                        self.states.append(.dragInside)
            } onDragOutside: { pos, size in
                // Uncomment to try it out!
                //                        states.removeFirst()
                //                        self.pos = pos
                //                        self.states.append(.dragOutside)
            } onDragEnter: { pos, size in
                states.removeFirst()
                self.pos = pos
                self.states.append(.dragEnter)
            } onDragExit: { pos, size in
                states.removeFirst()
                self.pos = pos
                self.states.append(.dragExit)
            }
            Text("History")
                .font(.system(size: 18, weight: .bold))
            ForEach(0..<10) { stateIndex in
                if stateIndex < states.count {
                    Text("\(stateIndex+1) \(stateText(states[stateIndex]))")
                }
            }
            
        }
        .frame(width: 450, height: 600, alignment: .center)
    }
    
    private func stateText(_ state: TouchState) -> String {
        switch state {
        case .touchDown:
            return "touchDown"
        case .confirm:
            return "confirm"
        case .touchUp:
            return "touchUp"
        case .cancel:
            return "cancel"
        case .dragging:
            return "dragging"
        case .dragInside:
            return "dragInside"
        case .dragOutside:
            return "dragOutside"
        case .dragEnter:
            return "dragEnter"
        case .dragExit:
            return "dragExit"
        }
    }
}



#Preview {
    AllTouchGesturePreview()
}
