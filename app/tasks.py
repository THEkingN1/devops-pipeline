"""Business logic of the Task Tracker (kept separate so it is easy to unit-test)."""


class TaskStore:
    def __init__(self):
        self._tasks = []
        self._next_id = 1

    def add(self, title):
        title = (title or "").strip()
        if not title:
            raise ValueError("title must not be empty")
        task = {"id": self._next_id, "title": title, "done": False}
        self._tasks.append(task)
        self._next_id += 1
        return task

    def all(self):
        return list(self._tasks)

    def complete(self, task_id):
        for task in self._tasks:
            if task["id"] == task_id:
                task["done"] = True
                return task
        raise KeyError(task_id)

    def stats(self):
        done = sum(1 for t in self._tasks if t["done"])
        return {"total": len(self._tasks), "done": done, "pending": len(self._tasks) - done}
