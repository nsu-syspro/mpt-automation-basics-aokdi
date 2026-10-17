FROM gcc:latest

RUN apt-get update \
    && apt-get install -y --no-install-recommends make jq diffutils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /wordcount

COPY . .

RUN make check

CMD ["./build/wordcount"]

