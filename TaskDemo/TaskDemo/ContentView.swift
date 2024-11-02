import SwiftUI

@Observable
final class Model {
    init() {
        print("INIT")
    }

    func load() async {
        print("LOAD")
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            Tab.Body("Tab 1", systemImage: "gear") {
                NavigationStack {
                    ViewA()
                }
            }
            Tab.Body("Tab 2", systemImage: "gear") {
                Color.green
            }

        }
    }
}

struct ViewA: View {
    @State var model = Model()
    @State private var isModal = false
    @State private var isPush = false

    var body: some View {

        VStack {
            Button("Present Modal") {
                isModal = true
            }

            Button("Push") {
                isPush = true
            }
        }
        .buttonStyle(.borderedProminent)
        .fullScreenCover(isPresented: $isModal) {
            ViewB()
        }
        .navigationDestination(isPresented: $isPush) {
            ViewB()
        }
        .taskFirstAppearance {
            await model.load()
        }
    }
}

struct ViewB: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Color.blue
            .onTapGesture {
                dismiss()
            }
    }
}

struct TaskFirstAppearanceModifier: ViewModifier {
    @State private var hasRunTask = false
    let task: () async -> Void

    func body(content: Content) -> some View {
        content.task {
            guard !hasRunTask else { return }

            hasRunTask = true

            await self.task()
        }
    }
}

extension View {
    func taskFirstAppearance(task: @escaping () async -> Void) -> some View {
        modifier(TaskFirstAppearanceModifier(task: task))
    }
}

#Preview {
    ContentView()
}
