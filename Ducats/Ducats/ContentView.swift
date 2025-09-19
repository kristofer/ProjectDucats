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
    @State private var showCompletedProjects = false
    @State private var showCompletedOnly = false
    @State private var selectedProject: Project? = nil

    var filteredProjects: [Project] {
        showCompletedOnly ? projects.filter { $0.completed } : projects.filter { !$0.completed }
    }

    var body: some View {
        NavigationSplitView {
            VStack {
                List(selection: $selectedProject) {
                    ForEach(filteredProjects) { project in
                        NavigationLink(value: project) {
                            VStack(alignment: .leading) {
                                Text(project.name)
                                    .font(.headline)
                                Text(project.details)
                                    .font(.subheadline)
                                Text(project.createdAt, format: Date.FormatStyle(date: .numeric, time: .standard))
                                    .font(.caption)
                            }
                        }
                    }
                    .onDelete(perform: deleteProjects)
                }
                Toggle("Completed Projects", isOn: $showCompletedOnly)
                    .padding(.horizontal)
                    .onChange(of: showCompletedOnly) { _,_ in
                        selectedProject = nil
                    }
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
            if let project = selectedProject {
                ProjectDetailView(project: project)
            } else {
                Text("Select a project")
            }
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
