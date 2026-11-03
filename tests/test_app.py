import pytest
from app.app import create_app
from app.tasks import TaskStore


def test_add_task_and_stats():
    store = TaskStore()
    store.add("Learn CI/CD")
    store.add("Write tests")
    store.complete(1)
    assert store.stats() == {"total": 2, "done": 1, "pending": 1}


def test_empty_title_rejected():
    with pytest.raises(ValueError):
        TaskStore().add("   ")


def test_complete_unknown_task():
    with pytest.raises(KeyError):
        TaskStore().complete(99)


@pytest.fixture
def client():
    return create_app().test_client()


def test_health_endpoint(client):
    res = client.get("/health")
    assert res.status_code == 200
    assert res.get_json()["status"] == "ok"


def test_create_and_list_tasks(client):
    assert client.post("/tasks", json={"title": "Deploy"}).status_code == 201
    assert client.get("/tasks").get_json()[0]["title"] == "Deploy"


def test_create_task_validation(client):
    assert client.post("/tasks", json={"title": ""}).status_code == 400
