FROM nginx:alpine

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY Draft/index.html /usr/share/nginx/html/index.html
COPY Draft/css/ /usr/share/nginx/html/css/
COPY Draft/js/ /usr/share/nginx/html/js/

EXPOSE 80
