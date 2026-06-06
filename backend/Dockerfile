# ==========================================
# STAGE 1: Compilation Environment
# ==========================================
FROM golang:1.22-alpine AS builder

# Install core build-essential tools for caching dependencies if needed
RUN apk add --no-cache git

# Set runtime workspace inside the compiler container
WORKDIR /app

# Copy dependency mappings first to optimize image caching layers
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the application source code
COPY . .

# Compile the monolithic binary into a highly compressed static executable
# Note: ./cmd/... automatically finds and builds the main package inside the cmd/ subdirectory
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o starttech-api ./cmd/...

# ==========================================
# STAGE 2: Lightweight Production Execution Mirror
# ==========================================
FROM alpine:3.19

# Install runtime security certificates and debugging/health utilities
RUN apk --no-cache add ca-certificates tzdata curl

WORKDIR /root/

# Pull down the compiled static bundle exclusively from the builder container
COPY --from=builder /app/starttech-api .

# Expose port 8080 to map back exactly to our structural ALB target paths
EXPOSE 8080

# Enforce default production environment variables
ENV PORT=8080
ENV ENV=production

# Fire up the engine runtime
CMD ["./starttech-api"]
