FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install libpq-dev -y

COPY ./target/release/server .

CMD ["./server"]