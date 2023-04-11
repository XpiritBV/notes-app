#! /bin/bash 
docker build -t notesappdev:latest --output type=docker . && docker run -p 80:80 --rm -it notesappdev:latest
