
import SwiftUI
import SwiftData

@Model
class Task: Identifiable {
    var id = UUID()
    var title: String
    var isDone: Bool
    var dueDate: Date?
    var category: Category?

    init(title: String,
         isDone: Bool = false,
         dueDate: Date? = nil,
         category: Category? = nil
    ) {
        self.title = title
        self.isDone = isDone
        self.dueDate = dueDate
        self.category = category
    }
}


@Model
class Category: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \Task.category)
    var tasks: [Task] = []

    init(name: String) {
        self.name = name
    }
}

struct CategoryListView: View {
    @Query private var categories: [Category]
    @Environment(\.modelContext) private var modelContext

    @State private var newCategoryName: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Новая категория", text: $newCategoryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Добавить") {
                        addCategory()
                    }
                }
                .padding()

                List {
                    ForEach(categories) { category in
                        NavigationLink(destination: TaskListView(category: category)) {
                            HStack {
                                Text(category.name)
                                Spacer()
                                Text("\(category.tasks.count) задач")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteCategories)
                }
            }
            .navigationTitle("Категории")
        }
    }

    func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        let newCategory = Category(name: newCategoryName)
        modelContext.insert(newCategory)
        try? modelContext.save()
        newCategoryName = ""
    }

    func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            modelContext.delete(category)
        }
        try? modelContext.save()
    }
}

struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var tasks: [Task]

    let category: Category

    @State private var newTitle = ""

    init(category: Category) {
        self.category = category
        let categoryID = category.id
        _tasks = Query(filter: #Predicate<Task> { task in
            task.category?.id == categoryID
        })
    }

    var body: some View {
        VStack {
            HStack {
                TextField("Новая задача", text: $newTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Добавить") {
                    addTask()
                }
            }
            .padding()

            List {
                ForEach(tasks) { task in
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.headline)

                        if let date = task.dueDate {
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteTasks)
            }
        }
        .navigationTitle(category.name)
    }

    private func addTask() {
        guard !newTitle.isEmpty else { return }
        let newTask = Task(title: newTitle, dueDate: Date(), category: category)
        modelContext.insert(newTask)
        try? modelContext.save()
        newTitle = ""
    }

    private func deleteTasks(at offsets: IndexSet) {
        offsets.map { tasks[$0] }.forEach(modelContext.delete)
        try? modelContext.save()
    }
}

