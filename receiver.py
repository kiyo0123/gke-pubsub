# -*- coding: utf-8 -*-
import datetime

#from google.cloud import pubsub
from google.cloud import pubsub_v1
import time
import os

PUBSUB_TOPIC = os.getenv("PUBSUB_TOPIC", "echo")
PROJECT = os.getenv("PROJECT", "fukudak-gke")
PUBSUB_SUBSCRIPTION = os.getenv("PUBSUB_SUBSCRIPTION", "echo-read")

def receive_messages(project, subscription_name):
    """Receives messages from a pull subscription."""
    subscriber = pubsub_v1.SubscriberClient()
    subscription_path = subscriber.subscription_path(
        project, subscription_name)

    def callback(message):
        print('Received message: {}'.format(message))
        message.ack()

    subscriber.subscribe(subscription_path, callback=callback)

    # The subscriber is non-blocking, so we must keep the main thread from
    # exiting to allow it to process messages in the background.
    print('Listening for messages on {}'.format(subscription_path))
    while True:
        time.sleep(60)

if __name__ == '__main__':
    receive_messages(PROJECT, PUBSUB_SUBSCRIPTION)

