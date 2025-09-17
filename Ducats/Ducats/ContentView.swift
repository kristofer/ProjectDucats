//
//  ContentView.swift
//  Ducats
//
//  Created by Kristofer Younger on 9/17/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(projects) { project in
                    NavigationLink {
                        ProjectDetailView(project: project)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(project.name)
                                .font(.headline)
                            Text(project.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))
                                .font(.caption)
                        }
                    }
                }
                .onDelete(perform: deleteProjects)
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addProject) {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a project")
        }
    }

    private func addProject() {
        withAnimation {
            let newProject = Project(name: "New Project", details: "", createdAt: Date())
            modelContext.insert(newProject)
        }
    }

    private func deleteProjects(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(projects[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Project.self, inMemory: true)
}
