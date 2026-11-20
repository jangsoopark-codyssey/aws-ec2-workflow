#!/bin/bash

docker run -d --name draft-web --restart unless-stopped -p 80:80 draft-web:1.0
