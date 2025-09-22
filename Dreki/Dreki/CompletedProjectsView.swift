import SwiftUI
import SwiftData

struct CompletedProjectsView: View {
    let projects: [Project]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack {
                List(projects) { project in
                    VStack(alignment: .leading) {
                        Text(project.name)
                            .font(.headline)
                        Text(project.details)
                            .font(.subheadline)
                        Text(project.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))
                            .font(.caption)
                    }
                }
                Button("Done") {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("Completed Projects")
        }
    }
}

#Preview {
    CompletedProjectsView(projects: [
        Project(name: "Completed Project", details: "Details", createdAt: Date(), completed: true)
    ])
}
