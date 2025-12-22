ARG TARGET=x86_64-unknown-linux-musl

FROM rust:1.85-alpine AS builder
ARG TARGET
RUN apk add --no-cache musl-dev openssl-dev perl make
WORKDIR /app
COPY . .
RUN rustup target add ${TARGET}
RUN cargo build --release --target ${TARGET}

FROM alpine:3.19
RUN apk add --no-cache openssl ca-certificates
ARG TARGET
COPY --from=builder /app/target/${TARGET}/release/redlib /usr/local/bin/redlib
RUN chmod +x /usr/local/bin/redlib
RUN adduser --home /nonexistent --no-create-home --disabled-password redlib
USER redlib

EXPOSE 8080
HEALTHCHECK --interval=1m --timeout=3s CMD wget --spider -q http://localhost:8080/settings || exit 1
CMD ["redlib"]
