import UIKit
import Toolkit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

func mainThreadText() -> String {
    Thread.isMainThread ? "[MAIN]" : "[BACKGROUND]"
}

func startTasksOnMain() {
    print("\(mainThreadText()) Starting Task 1")
    let task1 = Task.runOnMainThreadAfter(seconds: 10) {
        print("\(mainThreadText()) Task 1 executed")
    } onCancelled: {
        print("\(mainThreadText()) Task 1 cancelled")
    }

    print("\(mainThreadText()) Starting Task 2")
    Task.runOnMainThreadAfter(seconds: 2) {
        task1.cancel()
        print("\(mainThreadText()) Task 2 cancelled Task 1")
        print("")
        startTasksOnBackground()
    }
}

func startTasksOnBackground() {
    print("\(mainThreadText()) Starting Task 3")
    let task3 = Task.runAfter(seconds: 10) {
        print("\(mainThreadText()) Task 3 executed")
    } onCancelled: {
        print("\(mainThreadText()) Task 3 cancelled")
    }

    print("\(mainThreadText()) Starting Task 4")
    Task.runAfter(seconds: 2) {
        task3.cancel()
        print("\(mainThreadText()) Task 4 cancelled Task 3")
    }
}

startTasksOnMain()
