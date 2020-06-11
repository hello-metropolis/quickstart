# Metropolis
## Quickstart Frontend

### Setup

The following command will build the docker image for this project.  Replace `kenmazaika` with your handle.

**Build** the docker image, by running this command and replacing `PROJECT_ID` with the project id you're using on Google Cloud Platform.

```
docker build . -t PROJECT_ID/metropolis-quickstart-frontend:latest
```

**Run** the docker image, by running this command and replacing `PROJECT_ID` with the project id you're using on Google Cloud Platform.

```
docker run -p 8082:80 PROJECT_ID/metropolis-quickstart-frontend:latest
```

**Shell** into the docker image, by running this command and replacing `PROJECT_ID` with the project id you're using on Google Cloud Platform.

```
docker run -ti PROJECT_ID/metropolis-quickstart-frontend /bin/sh
cd /usr/share/nginx/html
```

**Push** to GCR.io, by running this command and replacing `PROJECT_ID` with the project id you're using on Google Cloud Platform.


```
docker tag PROJECT_ID/metropolis-quickstart-frontend:latest gcr.io/PROJECT_ID/metropolis-quickstart/frontend:latest

docker push gcr.io/PROJECT_ID/metropolis-quickstart/frontend:latest
```


**Install Helm Chart** to Kubernetes, with:

```
helm install metropolis-quickstart-frontend infrastructure/helm/frontend/
```