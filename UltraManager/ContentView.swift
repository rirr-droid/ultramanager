import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var runners: [Runner]
    @State private var showingRunnerCreation = false

    var body: some View {
        Group {
            if let runner = runners.first {
                MainHubView(runner: runner)
            } else {
                WelcomeView(showingRunnerCreation: $showingRunnerCreation)
            }
        }
        .sheet(isPresented: $showingRunnerCreation) {
            RunnerCreationView(modelContext: modelContext)
        }
    }
}

struct WelcomeView: View {
    @Binding var showingRunnerCreation: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Text("ULTRA MANAGER")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Build your ultrarunning career\nFrom first 50K to UTMB")
                    .font(.system(size: 18, design: .monospaced))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Spacer()

                Button {
                    showingRunnerCreation = true
                } label: {
                    Text("START CAREER")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}
