FROM debian:9.5-slim
COPY . /app
WORKDIR /app
RUN ./test_minimal
