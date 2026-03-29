import SwiftUI
import SwiftData

struct RunnerCreationView: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext

    @State private var name: String = ""
    @State private var selectedArchetype: ArchetypeKey = .allRounder
    @State private var selectedGender: String = "male"
    @State private var selectedNationality: String = "USA"

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        Text("CREATE YOUR RUNNER")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.orange)
                            .padding(.top, 20)

                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.gray)
                            TextField("Enter name", text: $name)
                                .font(.system(size: 18, design: .monospaced))
                                .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)

                        // Gender
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Gender")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.gray)
                            Picker("Gender", selection: $selectedGender) {
                                Text("Male").tag("male")
                                Text("Female").tag("female")
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal)

                        // Archetype Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Your Archetype")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)

                            ForEach(Archetype.all, id: \.id) { archetype in
                                ArchetypeCard(
                                    archetype: archetype,
                                    isSelected: selectedArchetype == archetype.id
                                ) {
                                    selectedArchetype = archetype.id
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Create Button
                        Button {
                            createRunner()
                        } label: {
                            Text("BEGIN JOURNEY")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(name.isEmpty ? Color.gray : Color.orange)
                                .cornerRadius(8)
                        }
                        .disabled(name.isEmpty)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                }
            }
        }
    }

    private func createRunner() {
        let archetype = Archetype.get(selectedArchetype)
        let runner = Runner(name: name, archetype: archetype, gender: selectedGender, nationality: selectedNationality)
        modelContext.insert(runner)
        try? modelContext.save()
        dismiss()
    }
}

struct ArchetypeCard: View {
    let archetype: Archetype
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(archetype.name)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.orange)
                    }
                }

                Text(archetype.description)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)

                Text(archetype.backstory)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray.opacity(0.7))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)

                Text(archetype.passive.rawValue)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.orange)
                    .padding(.top, 4)

                // Starting stats preview
                HStack(spacing: 12) {
                    statPreview("SPD", value: archetype.stats["speed"] ?? 5)
                    statPreview("END", value: archetype.stats["endurance"] ?? 5)
                    statPreview("CLB", value: archetype.stats["climbing"] ?? 5)
                    statPreview("MNT", value: archetype.stats["mental"] ?? 5)
                }
                .padding(.top, 8)
            }
            .padding()
            .background(isSelected ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func statPreview(_ label: String, value: Double) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.gray)
            Text(String(format: "%.1f", value))
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(statColor(value))
        }
    }

    private func statColor(_ value: Double) -> Color {
        if value >= 8 { return .green }
        if value >= 6 { return .orange }
        if value >= 4 { return .yellow }
        return .red
    }
}
