import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project

    @State private var isEditing = false
    @State private var showAddExpense = false
    @State private var newAmount: String = ""
    @State private var newDesc: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isEditing {
                TextField("Project Name", text: $project.name)
                    .font(.title)
                TextField("Details", text: $project.details)
                    .font(.body)
            } else {
                Text(project.name)
                    .font(.title)
                Text(project.details)
                    .font(.body)
            }
            HStack {
                Button(isEditing ? "Save" : "Edit") {
                    isEditing.toggle()
                    if !isEditing {
                        try? modelContext.save()
                    }
                }
                .buttonStyle(.bordered)
            }
            Divider()
            Text("Ledger")
                .font(.headline)
            List {
                ForEach(project.expenses) { expense in
                    VStack(alignment: .leading) {
                        Text("$\(expense.amount, specifier: "%.2f")")
                            .font(.body)
                        Text(expense.date, format: Date.FormatStyle(date: .numeric, time: .standard))
                            .font(.caption)
                        Text(expense.desc)
                            .font(.caption)
                    }
                }
                .onDelete(perform: deleteExpenses)
            }
            Button("Add Expense") {
                showAddExpense = true
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $showAddExpense) {
                VStack(spacing: 16) {
                    Text("New Expense")
                        .font(.headline)
                    TextField("Amount", text: $newAmount)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $newDesc)
                    HStack {
                        Button("Cancel") {
                            showAddExpense = false
                            newAmount = ""
                            newDesc = ""
                        }
                        Button("Save") {
                            if let amount = Double(newAmount) {
                                let expense = Expense(amount: amount, description: newDesc, project: project)
                                project.expenses.append(expense)
                                try? modelContext.save()
                            }
                            showAddExpense = false
                            newAmount = ""
                            newDesc = ""
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
        .navigationTitle("Project Details")
    }

    private func deleteExpenses(offsets: IndexSet) {
        for index in offsets {
            let expense = project.expenses[index]
            project.expenses.remove(at: index)
            modelContext.delete(expense)
        }
        try? modelContext.save()
    }
}

extension Binding where Value == String? {
    init(_ source: Binding<String?>, replacingNilWith defaultValue: String) {
        self.init(get: { source.wrappedValue ?? defaultValue }, set: { source.wrappedValue = $0 })
    }
}

#Preview {
    let project = Project(name: "Preview Project", details: "Preview details")
    return ProjectDetailView(project: project)
}
