GCLOUD_PROJECT:=$(shell gcloud config list project --format="value(core.project)")
SERVICE_ACCOUNT:="pubsub-app"
TOPIC:="echo"

pubsub:
	gcloud pubsub topics create ${TOPIC}
	gcloud pubsub subscriptions create ${TOPIC}-read --topic ${TOPIC}
	
build:
	gcloud container builds submit --tag gcr.io/${GCLOUD_PROJECT}/receiver:v1 .

service-account:
	gcloud iam service-accounts create ${SERVICE_ACCOUNT}
	gcloud projects add-iam-policy-binding ${GCLOUD_PROJECT} \
		--member "serviceAccount:${SERVICE_ACCOUNT}@${GCLOUD_PROJECT}.iam.gserviceaccount.com" \
		--role "roles/pubsub.subscriber"
	gcloud iam service-accounts keys create ${GCLOUD_PROJECT}-${SERVICE_ACCOUNT}.json \
		--iam-account ${SERVICE_ACCOUNT}@${GCLOUD_PROJECT}.iam.gserviceaccount.com

gke-deploy:
	kubectl create configmap pubsub-config --from-literal=PROJECT=$(shell gcloud config list project --format="value(core.project)") \
		--from-literal=PUBSUB_TOPIC=${TOPIC} \
		--from-literal=PUBSUB_SUBSCRIPTION=${TOPIC}-read
	kubectl create secret generic pubsub-key --from-file=key.json=${GCLOUD_PROJECT}-${SERVICE_ACCOUNT}.json
	kubectl apply -f deployment/pubsub-with-secret.yaml

clean:
	kubectl delete deployment/pubsub
	kubectl delete secret pubsub-key
	gcloud pubsub subscriptions delete ${TOPIC}-read
	gcloud pubsub topics delete ${TOPIC}
	gcloud iam service-accounts delete ${SERVICE_ACCOUNT}
	
