# AllTouchGestureModifier

![](https://github.com/richardjorne/AllTouchGestureModifier/blob/main/header.gif?raw=true =300x300)

.allTouchGestureModifier is a SwiftUI modifier that enables you to access the most useful touch gestures in UIKit and even touch position.

This is also a good option if you just want to obtain the touch position.

.allTouchGestureModifier是一个SwiftUI的Modifier。有了它，你就可以使用UIKit中最重要的几个点按手势。不仅如此，你还可以访问点按位置！
哪怕只是为了获取点按位置，.allTouchGestureModifier也值得尝试！


| Supported Gesture      |
| ---------------------- |
| touchDown              |
| confirm(touchUpInside) |
| touchUp                |
| cancel(touchUpOutside) |
| dragging               |
| dragInside             |
| dragOutside            |
| dragEnter              |
| dragExit               |


# Installation 安装

## Swift Package

Using Swift Package, simply paste the following link:

用 Swift Package的话，直接CV以下链接:

```
https://github.com/richardjorne/AllTouchGestureModifier.git
```

## File Copy

Simply copy the file Sources/AllTouchGestureModifier.swift to your project.

或者直接复制Sources/AllTouchGestureModifier.swift到你的项目。

# Usage 使用方法

On any View you want to detect the gestures, simply add the modifier and provide the closure you want to use.

在任何需要检测手势的View上使用Modifier并提供对应的闭包就可以了。

## Example

Note that you need to `import AllTouchGestureModifier` first.

记得加上`import AllTouchGestureModifier` .

```swift
struct AllTouchGesturePreview: View {
    
    @State private var pos: CGPoint = .zero
    @State private var states: [TouchState] = [.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp,.touchUp]
    
    var body: some View {
        VStack {
            ZStack {
                Color.yellow.frame(width: 200, height: 200)
                    .allTouchGesture { pos in
                        states.removeFirst()
                        self.pos = pos
                        self.states.append(.touchDown)
                    } onConfirm: { pos in
                        states.removeFirst()
                        self.pos = pos
                        self.states.append(.confirm)
                    } onTouchUp: { pos in
                        states.removeFirst()
                        self.pos = pos
                        self.states.append(.touchUp)
                    } onCancel: { pos in
                        states.removeFirst()
                        self.pos = pos
                        self.states.append(.cancel)
                    }
                // Notice how multiple allTouchGesture's behavior can be cumulated.
                    .allTouchGesture{_ in } onDragging: { pos in
                        self.pos = pos
                        //                        states.removeFirst()
                        //                        self.states.append(.dragging)
                    } onDragInside: { pos in
                        // Uncomment to try it out!
                        //                        states.removeFirst()
                        //                        self.pos = pos
                        //                        self.states.append(.dragInside)
                    } onDragOutside: { pos in
                        // Uncomment to try it out!
                        //                        states.removeFirst()
                        //                        self.pos = pos
                        //                        self.states.append(.dragOutside)
                    } onDragEnter: { pos in
                        states.removeFirst()
                        self.pos = pos
                        self.states.append(.dragEnter)
                    } onDragExit: { pos in
                        states.removeFirst()
                        self.pos = pos
                        self.states.append(.dragExit)
                    }
                
                
                VStack {
                    Text(stateText(states.last ?? .touchUp))
                    Text("\(String(format: "%.2f", pos.x)), \(String(format: "%.2f", pos.y))")
                }
                .font(.system(size: 20, weight: .bold))
            }
            Text("History")
                .font(.system(size: 18, weight: .bold))
            ForEach(0..<10) { stateIndex in
                if stateIndex < states.count {
                    Text("\(stateIndex+1) \(stateText(states[stateIndex]))")
                }
            }
            
        }
        .frame(width: 400, height: 600, alignment: .center)
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

```
