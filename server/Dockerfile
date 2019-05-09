FROM ubuntu:18.04

ARG DATABASE_URL
ENV DATABASE_URL ${DATABASE_URL}

RUN apt-get update
RUN apt-get install libpq-dev -y

COPY ./target/release/server .

CMD ["./server"]