import json
from locust import HttpUser, task, between
from locust import events
from locust.runners import MasterRunner


class ApiTest(HttpUser):
    def __init__(self, parent):
        super(ApiTest, self).__init__(parent)
        self.headers = {}

    wait_time = between(1, 5)

    def on_start(self):
        response = self.client.post("auth/login", json={"username": "lassaut", "password": "lassaut"})
        token = json.loads(response._content)['token']
        self.headers = {'token': token}

    @task
    def me(self):
      for i in range(1,100000):
        response = self.client.get("profile/me", headers=self.headers)