import os
from flask import Flask, jsonify, request
from app.tasks import TaskStore

VERSION = os.environ.get("APP_VERSION", "1.0.0")


def create_app():
    app = Flask(__name__)
    store = TaskStore()

    @app.get("/")
    def index():
        return (
            "<h1>Task Tracker</h1><p>DevOps Pipeline midterm project.</p>"
            f"<p>Version: {VERSION}</p><p>Endpoints: /health, /tasks, /stats</p>"
        )

    @app.get("/health")
    def health():
        return jsonify(status="ok", version=VERSION)

    @app.get("/tasks")
    def list_tasks():
        return jsonify(store.all())

    @app.post("/tasks")
    def add_task():
        data = request.get_json(silent=True) or {}
        try:
            return jsonify(store.add(data.get("title"))), 201
        except ValueError as exc:
            return jsonify(error=str(exc)), 400

    @app.post("/tasks/<int:task_id>/done")
    def done(task_id):
        try:
            return jsonify(store.complete(task_id))
        except KeyError:
            return jsonify(error="not found"), 404

    @app.get("/stats")
    def stats():
        return jsonify(store.stats())

    return app


if __name__ == "__main__":
    create_app().run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
