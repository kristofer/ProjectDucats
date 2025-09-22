import SwiftUI
import SwiftData
import PhotosUI

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
    @State private var newReceiptImage: PhotosPickerItem? = nil
    @State private var newReceiptImageData: Data? = nil
    @State private var editReceiptImage: PhotosPickerItem? = nil
    @State private var editReceiptImageData: Data? = nil
    @State private var viewingReceiptImageData: Data? = nil
    @State private var showExportError = false
    @State private var exportErrorMessage = ""
    @State private var showExportSuccess = false
    @State private var exportSuccessMessage = ""
    @State private var showDocumentPicker = false
    @State private var exportfileObj: ExportFile? = nil
    @State private var showMailView = false
    @State private var mailAttachment: MailAttachment? = nil

    enum SortOrder: String, CaseIterable, Identifiable {
        case dateDescending = "Date ↓"
        case dateAscending = "Date ↑"
        case amountDescending = "Amount ↓"
        case amountAscending = "Amount ↑"
        var id: String { rawValue }
    }

    var sortedFilteredExpenses: [Expense] {
        var filtered = (project.expenses ?? []).filter { filterText.isEmpty || $0.desc.localizedCaseInsensitiveContains(filterText) }
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
        (project.expenses ?? []).reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isEditing {
                TextField("Project Name", text: $project.name)
                    .font(.title)
                TextField("Details", text: $project.details)
                    .font(.body)
                Toggle("Completed", isOn: $project.completed)
                    .onChange(of: project.completed) {
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
                Button("Export CSV") {
                    exportCSV()
                }
                .buttonStyle(.bordered)
                Button("Email CSV") {
                    prepareAndShowMailView()
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
                        editReceiptImageData = expense.receiptImageData
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
                            if let imageData = expense.receiptImageData {
                                #if canImport(UIKit)
                                if let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                }
                                #elseif canImport(AppKit)
                                if let nsImage = NSImage(data: imageData) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                        .cornerRadius(8)
                                }
                                #endif
                                Button("View Receipt") {
                                    viewingReceiptImageData = imageData
                                }
                                .buttonStyle(.bordered)
                            }
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
                    if let imageData = newReceiptImageData {
                        #if canImport(UIKit)
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(8)
                        }
                        #elseif canImport(AppKit)
                        if let nsImage = NSImage(data: imageData) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .cornerRadius(8)
                        }
                        #endif
                        Button("Remove Receipt Image") {
                            newReceiptImageData = nil
                        }
                    }
                    PhotosPicker(selection: $newReceiptImage, matching: .images) {
                        Text(newReceiptImageData == nil ? "Add Receipt Image" : "Change Receipt Image")
                    }
                    .onChange(of: newReceiptImage) {
                        guard let newReceiptImage else { return }
                        Task {
                            if let data = try? await newReceiptImage.loadTransferable(type: Data.self) {
                                newReceiptImageData = data
                            }
                        }
                    }
                    HStack {
                        Button("Cancel") {
                            showAddExpense = false
                            newAmount = ""
                            newDesc = ""
                            newWhere = ""
                            newWhat = ""
                            newReceiptImageData = nil
                            newReceiptImage = nil
                        }
                        Button("Save") {
                            if let amount = Double(newAmount) {
                                let expense = Expense(amount: amount, description: newDesc, receiptImageData: newReceiptImageData, project: project, whereMade: newWhere, whatPurchased: newWhat)
                                if project.expenses == nil {
                                    project.expenses = []
                                }
                                project.expenses?.append(expense)
                                try? modelContext.save()
                            }
                            showAddExpense = false
                            newAmount = ""
                            newDesc = ""
                            newWhere = ""
                            newWhat = ""
                            newReceiptImageData = nil
                            newReceiptImage = nil
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
                if let imageData = editReceiptImageData {
                    #if canImport(UIKit)
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(8)
                    }
                    #elseif canImport(AppKit)
                    if let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(8)
                    }
                    #endif
                    Button("Remove Receipt Image") {
                        editReceiptImageData = nil
                    }
                }
                PhotosPicker(selection: $editReceiptImage, matching: .images) {
                    Text(editReceiptImageData == nil ? "Add Receipt Image" : "Change Receipt Image")
                }
                .onChange(of: editReceiptImage) {
                    guard let editReceiptImage else { return }
                    Task {
                        if let data = try? await editReceiptImage.loadTransferable(type: Data.self) {
                            editReceiptImageData = data
                        }
                    }
                }
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
                            expense.receiptImageData = editReceiptImageData
                            try? modelContext.save()
                        }
                        editingExpense = nil
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: Binding<Bool>(get: { viewingReceiptImageData != nil }, set: { if !$0 { viewingReceiptImageData = nil } })) {
            if let imageData = viewingReceiptImageData {
                ZoomableImageView(imageData: imageData)
            }
        }
#if os(iOS)
        .sheet(isPresented: Binding<Bool>(
            get: { showDocumentPicker && exportfileObj != nil },
            set: { newValue in
                showDocumentPicker = newValue
                if !newValue { exportfileObj = nil }
            })
        ) {
            if let exportfile = exportfileObj {
                Text(String(describing: exportfile.url))
                DocumentPickerView(exportFile: exportfile) {
                    print("DocumentPickerView dismissed")
                    showDocumentPicker = false
                    exportfileObj = nil
                }
            } else {
                Text("No file to export")
            }
        }
#endif

        .alert(isPresented: $showExportError) {
            Alert(title: Text("Export Failed"), message: Text(exportErrorMessage), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showExportSuccess) {
            Alert(title: Text("Export Successful"), message: Text(exportSuccessMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(item: $mailAttachment, onDismiss: { mailAttachment = nil }) { attachment in
            MailView(
                subject: "Project Expenses CSV",
                body: "Attached is the CSV file for project \(project.name).",
                recipients: nil,
                attachmentData: attachment.data,
                attachmentMimeType: "text/csv",
                attachmentFileName: attachment.fileName
            )
        }
    }

    private func deleteExpenses(offsets: IndexSet) {
        guard let _ = project.expenses else { return }
        for index in offsets {
            if let expense = project.expenses?[index] {
                project.expenses?.remove(at: index)
                modelContext.delete(expense)
            }
        }
        try? modelContext.save()
    }

    private func makeCSVString() -> String {
        let expenses = project.expenses ?? []
        let header = "Amount,Date,Description,Where,What\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let rows = expenses.map { expense in
            let amount = String(format: "%.2f", expense.amount)
            let date = dateFormatter.string(from: expense.date)
            let desc = expense.desc.replacingOccurrences(of: ",", with: " ")
            let whereMade = expense.whereMade.replacingOccurrences(of: ",", with: " ")
            let whatPurchased = expense.whatPurchased.replacingOccurrences(of: ",", with: " ")
            return "\(amount),\(date),\(desc),\(whereMade),\(whatPurchased)"
        }.joined(separator: "\n")
        return header + rows + "\n"
    }

    private func exportCSV() {
        let csvString = makeCSVString()
        let sanitizedName = project.name.replacingOccurrences(of: "[^A-Za-z0-9_-]", with: "_", options: .regularExpression)
        let fileName = sanitizedName + ".csv"
        #if os(macOS)
        let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let fileURL = downloadsURL.appendingPathComponent(fileName)
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            exportSuccessMessage = "\(fileName) was saved to your Downloads folder."
            showExportSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                showExportSuccess = false
            }
        } catch {
            exportErrorMessage = "Failed to write CSV: \(error.localizedDescription)"
            showExportError = true
        }
        #else
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            exportfileObj = ExportFile(url: tempURL) // Set file object first
            print("Prepared file at \(tempURL)")
            DispatchQueue.main.async {
                editingExpense = nil
                viewingReceiptImageData = nil
                showAddExpense = false
                showDocumentPicker = true // Only set flag after file object is ready
            }
        } catch {
            exportErrorMessage = "Failed to write CSV: \(error.localizedDescription)"
            showExportError = true
        }
        #endif
    }

    private func prepareAndShowMailView() {
        let csvString = makeCSVString()
        print("CSV String for email:", csvString)
        let sanitizedName = project.name.replacingOccurrences(of: "[^A-Za-z0-9_-]", with: "_", options: .regularExpression)
        let fileName = sanitizedName + ".csv"
        if let data = csvString.data(using: .utf8) {
            mailAttachment = MailAttachment(data: data, fileName: fileName)
        } else {
            exportErrorMessage = "Failed to encode CSV for email."
            showExportError = true
        }
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

struct ZoomableImageView: View {
    let imageData: Data
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var gestureScale: CGFloat = 1.0
    @GestureState private var gestureOffset: CGSize = .zero
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .padding()
            }
            GeometryReader { geometry in
                Group {
                    if let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale * gestureScale)
                            .offset(x: offset.width + gestureOffset.width, y: offset.height + gestureOffset.height)
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .updating($gestureScale) { value, state, _ in
                                            state = value
                                        }
                                        .onEnded { value in
                                            scale *= value
                                        },
                                    DragGesture()
                                        .updating($gestureOffset) { value, state, _ in
                                            state = value.translation
                                        }
                                        .onEnded { value in
                                            offset.width += value.translation.width
                                            offset.height += value.translation.height
                                        }
                                )
                            )
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
            .frame(minWidth: 600, minHeight: 600)
        }
        .background(Color.black.opacity(0.95))
        .ignoresSafeArea()
        #else
        GeometryReader { geometry in
            Group {
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale * gestureScale)
                        .offset(x: offset.width + gestureOffset.width, y: offset.height + gestureOffset.height)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .updating($gestureScale) { value, state, _ in
                                        state = value
                                    }
                                    .onEnded { value in
                                        scale *= value
                                    },
                                DragGesture()
                                    .updating($gestureOffset) { value, state, _ in
                                        state = value.translation
                                    }
                                    .onEnded { value in
                                        offset.width += value.translation.width
                                        offset.height += value.translation.height
                                    }
                            )
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
        .background(Color.black.opacity(0.9))
        .ignoresSafeArea()
        #endif
    }
}

struct ExportFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct MailAttachment: Identifiable {
    let id = UUID()
    let data: Data
    let fileName: String
}
