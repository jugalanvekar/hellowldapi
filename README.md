# simpleapi

Hello World API with Python and Flask
This repo contains files needed to create a Hello World API, using Python and Flask. The application is bundled in a container and deployed to a kubernetes cluster. The backend database is Postgres.

API functionality
Description: Saves/updates the given user's name and date of birth in the database.

Request: PUT /hello/John { "dateOfBirth": "2000-01-01" }

Response: 201 No Content

Description: Returns a hello/birthday message for the given user

Request: GET /hello/John

Response: 200 OK

when John's birthday is in 5 days: { "message": "Hello, John! Your birthday is in 5 days" }

when John's birthday is today: { "message": "Hello, John! Happy birthday" }

Details
The app is written in Python, using Flask framework

simpleapi.py is the actual app code
requirements.txt are the dependencies required to run the app
Dockerfile is used to build docker container
k8syamls is the folder containing required yaml files to deploy to kubernetes cluster
deployment.yaml - will create a deployment of 6 containers
configmap.yaml - will create environment variables needed by the application to run. make sure to fill these ones
secrets.yaml - will create environment variable containing db password, make sure to fill this one too
service.yaml - will create a service type LoadBalancer, exposing the application on a public IP
Deployment steps
I have tested this on Google Kubernetes Engine

Download/pull this repository: git clone https://github.com/jaguarrr/simpleapi.git

Go to the newly created directory cd simpleapi

Build and tag your docker image

$ docker build . -t jaguar/simpleapi
Sending build context to Docker daemon  63.49kB
Step 1/6 : FROM python:2
2: Pulling from library/python
3d77ce4481b1: Pull complete
534514c83d69: Pull complete
d562b1c3ac3f: Pull complete
4b85e68dc01d: Pull complete
b2b679cd961a: Pull complete
2e7962f127e2: Pull complete
204945cc2de5: Pull complete
4a9629d55d9d: Pull complete
Digest: sha256:8907ce99826e948f535e9e2524225a8c5b2d273f2b223c7fe7d82e1fb41efdc3
Status: Downloaded newer image for python:2
 ---> 43c5f3ee0928
Step 2/6 : WORKDIR /usr/src/app
Removing intermediate container a9c018374fd9
 ---> 23ca0863ba75
Step 3/6 : COPY requirements.txt ./
 ---> e158c0c0f81c
Step 4/6 : RUN pip install --no-cache-dir -r requirements.txt
 ---> Running in a486e76dfb1c
 ...
Removing intermediate container a486e76dfb1c
 ---> 44fb8d92849c
Step 5/6 : COPY simpleapi.py .
 ---> 7bc4081b0643
Step 6/6 : CMD [ "python", "./simpleapi.py" ]
 ---> Running in ac1d6a836fa9
Removing intermediate container ac1d6a836fa9
 ---> 9f66d97ba0c9
Successfully built 9f66d97ba0c9
Successfully tagged jaguar/simpleapi:latest
Make sure to push the image to docker hub: $ docker push jaguar/simpleapi

I'm assuming you have access to a MySQL server. You can use the simpleapi.sql file from this repo to create the database, the table and a user with required access. Please note you need to change the user password in the SQL file .

Once you have the DB sorted, please make sure you replaced the followings:

DBHOST: <INSERT_DB_IP_OR_HOST>
DBNAME: <INSERT_DB_NAME>
DBUSER: <INSERT_DB_USER>
with appropriate values in k8syamls/configmap.yaml file, and replaced the following:

  dbpass: <INSERT_BASE64_DB_PASS>
with appropriate base64 encoded value in k8syamls/secrets.yaml file.

Once you have sorted the above, check that you have your kubernetes cluster available:

$ kubectl get all
NAME             TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
svc/kubernetes   ClusterIP   10.55.240.1   <none>        443/TCP   2d
$
then just execute the kubectl apply command:

$ kubectl apply -f k8syamls/
configmap "simpleapi-configs" created
deployment "simpleapi" created
secret "dbpass" created
service "simpleapi" created
$
now check the resources and get the public IP of the app:

$ kubectl get all
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/simpleapi   6         6         6            6           3m

NAME                      DESIRED   CURRENT   READY     AGE
rs/simpleapi-796bf89569   6         6         6         3m

NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/simpleapi   6         6         6            6           3m

NAME                      DESIRED   CURRENT   READY     AGE
rs/simpleapi-796bf89569   6         6         6         3m

NAME                            READY     STATUS    RESTARTS   AGE
po/simpleapi-796bf89569-cczqb   1/1       Running   0          3m
po/simpleapi-796bf89569-fd6g8   1/1       Running   0          3m
po/simpleapi-796bf89569-glsng   1/1       Running   0          3m
po/simpleapi-796bf89569-mcdz2   1/1       Running   0          3m
po/simpleapi-796bf89569-n6srp   1/1       Running   0          3m
po/simpleapi-796bf89569-xj5c9   1/1       Running   0          3m

NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
svc/kubernetes   ClusterIP      10.55.240.1    <none>          443/TCP        2d
svc/simpleapi    LoadBalancer   10.55.249.83   35.202.53.166   80:30608/TCP   3m
$
Now check the functionality of the app:

$ curl 35.202.53.166/hello/Simon
Something went wrong ...
$ curl -H 'Content-Type: application/json' -X PUT -d '{"dateOfBirth":"2000-11-29"}' http://35.202.53.166/hello/Simon
No content
$ curl 35.202.53.166/hello/Simon
{ "message": "Hello, Simon! Your birthday is in 204 days" }
$ curl -H 'Content-Type: application/json' -X PUT -d '{"dateOfBirth":"2000-05-09"}' http://35.202.53.166/hello/Simon
No content
$ curl 35.202.53.166/hello/Simon
{ "message": "Hello, Simon! Happy Birthday!" }
$
