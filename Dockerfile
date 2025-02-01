# ================================
# Build image
# ================================
FROM swift:5.9-jammy as build

# Install OS updates
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y\
    && rm -rf /var/lib/apt/lists/*

# Set up a build area
WORKDIR /build

# Copy Package files first for better caching
COPY ./Package.* ./
RUN swift package resolve --skip-update

# Copy the whole repository
COPY . .

# Build with optimizations
RUN swift build -c release --static-swift-stdlib

# ================================
# Run image
# ================================
FROM swift:5.9-jammy-slim

# Create a vapor user and set home
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

# Set working directory
WORKDIR /app

# Copy built executable and static files
COPY --from=build /build/.build/release/App ./
COPY --from=build /build/Public ./Public
COPY --from=build /build/Database ./Database # If using SQLite

# Ensure files are read-only
RUN chmod -R a-w ./Public

# Switch user
USER vapor:vapor

# Expose the port
EXPOSE 8080

# Start the server
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
