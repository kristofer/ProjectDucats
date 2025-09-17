import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var project: Project

    @State private var isEditing = false
    @State private var showAddExpense = false
    @State private var newAmount: String = ""
    @State private var newDesc: String = ""
    @State private var newWhere: String = ""
    @State private var newWhat: String = ""
    @State private var sortOrder: SortOrder = .dateDescending
    @State private var filterText: String = ""
    @State private var editingExpense: Expense? = nil
    @State private var editAmount: String = ""
    @State private var editDesc: String = ""
    @State private var editWhere: String = ""
    @State private var editWhat: String = ""

    enum SortOrder: String, CaseIterable, Identifiable {
        case dateDescending = "Date ↓"
        case dateAscending = "Date ↑"
        case amountDescending = "Amount ↓"
        case amountAscending = "Amount ↑"
        var id: String { rawValue }
    }

    var sortedFilteredExpenses: [Expense] {
        var filtered = project.expenses.filter { filterText.isEmpty || $0.desc.localizedCaseInsensitiveContains(filterText) }
        switch sortOrder {
        case .dateDescending:
            filtered.sort { $0.date > $1.date }
        case .dateAscending:
            filtered.sort { $0.date < $1.date }
        case .amountDescending:
            filtered.sort { $0.amount > $1.amount }
        case .amountAscending:
            filtered.sort { $0.amount < $1.amount }
        }
        return filtered
    }

    var totalAmount: Double {
        project.expenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isEditing {
                TextField("Project Name", text: $project.name)
                    .font(.title)
                TextField("Details", text: $project.details)
                    .font(.body)
                Toggle("Completed", isOn: $project.completed)
                    .onChange(of: project.completed) { _ in
                        try? modelContext.save()
                    }
            } else {
                Text(project.name)
                    .font(.title)
                Text(project.details)
                    .font(.body)
                if project.completed {
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.green)
                }
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
            HStack {
                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(.menu)
                TextField("Filter", text: $filterText)
                    .textFieldStyle(.roundedBorder)
            }
            Text("Total: $\(totalAmount, specifier: "%.2f")")
                .font(.subheadline)
                .padding(.bottom, 4)
            List {
                ForEach(sortedFilteredExpenses) { expense in
                    Button(action: {
                        editingExpense = expense
                        editAmount = String(expense.amount)
                        editDesc = expense.desc
                        editWhere = expense.whereMade
                        editWhat = expense.whatPurchased
                    }) {
                        VStack(alignment: .leading) {
                            Text("$\(expense.amount, specifier: "%.2f")")
                                .font(.body)
                            Text(expense.date, format: Date.FormatStyle(date: .numeric, time: .standard))
                                .font(.caption)
                            Text(expense.desc)
                                .font(.caption)
                            Text("Where: \(expense.whereMade)")
                                .font(.caption2)
                            Text("What: \(expense.whatPurchased)")
                                .font(.caption2)
                        }
                    }
                    .buttonStyle(.plain)
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
                    TextField("Description", text: $newDesc)
                    TextField("Where", text: $newWhere)
                    TextField("What", text: $newWhat)
                    HStack {
                        Button("Cancel") {
                            showAddExpense = false
                            newAmount = ""
                            newDesc = ""
                            newWhere = ""
                            newWhat = ""
                        }
                        Button("Save") {
                            if let amount = Double(newAmount) {
                                let expense = Expense(amount: amount, description: newDesc, project: project, whereMade: newWhere, whatPurchased: newWhat)
                                project.expenses.append(expense)
                                try? modelContext.save()
                            }
                            showAddExpense = false
                            newAmount = ""
                            newDesc = ""
                            newWhere = ""
                            newWhat = ""
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
        .navigationTitle("Project Details")
        .sheet(item: $editingExpense) { expense in
            VStack(spacing: 16) {
                Text("Edit Expense")
                    .font(.headline)
                TextField("Amount", text: $editAmount)
                TextField("Description", text: $editDesc)
                TextField("Where", text: $editWhere)
                TextField("What", text: $editWhat)
                HStack {
                    Button("Cancel") {
                        editingExpense = nil
                    }
                    Button("Save") {
                        if let amount = Double(editAmount) {
                            expense.amount = amount
                            expense.desc = editDesc
                            expense.whereMade = editWhere
                            expense.whatPurchased = editWhat
                            try? modelContext.save()
                        }
                        editingExpense = nil
                    }
                }
            }
            .padding()
        }
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
