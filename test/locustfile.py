import json
import random
from locust import HttpUser, task, between
from locust import events
from locust.runners import MasterRunner


class ApiTest(HttpUser):
    def __init__(self, parent):
        super(ApiTest, self).__init__(parent)

    wait_time = between(1, 5)

    @task
    def test(self):
        randNumber=random.randint(7000, 10000)
        print(randNumber)
        response = self.client.get("test?fib_number="+str(randNumber))