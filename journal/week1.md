# Week 1 — App Containerization

### Containerize Backend and Frontend
Executed Docker-compose up and created images,
successfully opened port 4567 and got a JSON response back




## Homework Challenges

### Run Dockerfile CMD as an external script

- RUN means it creates an intermediate container, runs the script and freeze the new state of that container in a new intermediate image. The script won't   be run after that: your final image is supposed to reflect the result of that script.

