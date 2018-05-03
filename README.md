# setup
## Preparation 
1. Create PubSub topic and subscription
```
$ make pubsub
```

Try to run application can run correctly in local environment. 
```
$ python receiver.py
```
Push message to the topic and confirm receiver can receive message.  
```
$ gcloud beta pubsub topics publish echo --message "hello"
```

## Step to run on GKE
2. Create Docker image
```
$ make build
```

3. Create Servcie Account
```
$ make service-account
```

4. Deploy app to GKE
```
$ make gke-deploy
```

5. Confirm receiver can get message
Confirm pod name to run below command : 
```
$ kubectl get pods
```
then confirm log
```
$ kubectl logs -f [pod-name]
```
Let's try to publish message to the topic. 
```
$ gcloud beta pubsub topics publish echo --message "hello"
```