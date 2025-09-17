# Build stage
FROM golang:1.25-alpine AS builder

# Install git and ca-certificates (needed for downloading dependencies)
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Tidy dependencies and build the application
RUN go mod tidy && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o instanton-exporter .

# Final stage
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/instanton-exporter .

# Expose port
EXPOSE 9100

# Run the binary
ENTRYPOINT ["./instanton-exporter"]
