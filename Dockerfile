FROM golang:1.8-alpine AS build-env
RUN mkdir /go/src/app && apk update && apk add git 
RUN apt-get update && apt-get install -y procps
ADD main.go /go/src/app/
WORKDIR /go/src/app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app .

FROM scratch
WORKDIR /app
COPY --from=build-env /go/src/app/app .
ENTRYPOINT [ "./app" ]
