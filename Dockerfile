FROM alpine:3.7

RUN apk add --no-cache docker

COPY ./bin /bin

CMD ["/bin/loop-aws-ecr-login.sh"]
