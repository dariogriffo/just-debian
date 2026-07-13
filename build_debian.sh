JUST_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$JUST_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <just_version> <build_version> [architecture]"
    echo "Example: $0 1.56.0 1 arm64"
    echo "Example: $0 1.56.0 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, armel, armhf, riscv64, loong64, all"
    exit 1
fi

BUILD_DATE="$(date -R)"

# Function to map Debian architecture to the just release target triple
get_just_target() {
    local arch=$1
    case "$arch" in
        "amd64")   echo "x86_64-unknown-linux-musl" ;;
        "arm64")   echo "aarch64-unknown-linux-musl" ;;
        "armel")   echo "arm-unknown-linux-musleabihf" ;;
        "armhf")   echo "armv7-unknown-linux-musleabihf" ;;
        "riscv64") echo "riscv64gc-unknown-linux-musl" ;;
        "loong64") echo "loongarch64-unknown-linux-musl" ;;
        *)         echo "" ;;
    esac
}

# Download the upstream changelog once (shared across arches/distros)
fetch_changelog() {
    if [ ! -f changelog.upstream ]; then
        echo "Downloading upstream CHANGELOG.md for ${JUST_VERSION}..."
        if ! wget -q "https://raw.githubusercontent.com/casey/just/${JUST_VERSION}/CHANGELOG.md" -O changelog.upstream; then
            echo "❌ Failed to download upstream changelog"
            return 1
        fi
    fi
    return 0
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local target
    local just_release

    target=$(get_just_target "$build_arch")
    if [ -z "$target" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64, armel, armhf, riscv64, loong64"
        return 1
    fi

    just_release="just-$build_arch"
    local asset="just-${JUST_VERSION}-${target}"

    echo "Building for architecture: $build_arch using $asset"

    # Clean up any previous downloads for this architecture
    rm -rf "$just_release" || true
    rm -f "${asset}.tar.gz" || true

    # Download and extract the just binary bundle for this architecture.
    # The tarball is flat (no top-level dir), so extract into a per-arch folder.
    if ! wget "https://github.com/casey/just/releases/download/${JUST_VERSION}/${asset}.tar.gz"; then
        echo "❌ Failed to download just binary for $build_arch"
        return 1
    fi

    mkdir -p "$just_release"
    if ! tar -xf "${asset}.tar.gz" -C "$just_release"; then
        echo "❌ Failed to extract just binary for $build_arch"
        return 1
    fi

    rm -f "${asset}.tar.gz"

    # Build packages for appropriate Debian distributions.
    # riscv64 and loong64 are only release architectures from trixie (v13) onwards.
    if [ "$build_arch" = "riscv64" ] || [ "$build_arch" = "loong64" ]; then
        declare -a arr=("trixie" "forky" "sid")
    else
        declare -a arr=("bookworm" "trixie" "forky" "sid")
    fi

    for dist in "${arr[@]}"; do
        FULL_VERSION="$JUST_VERSION-${BUILD_VERSION}~${dist}_${build_arch}"
        echo "  Building $FULL_VERSION"

        if ! docker build . -t "just-$dist-$build_arch" \
            --build-arg DEBIAN_DIST="$dist" \
            --build-arg JUST_VERSION="$JUST_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg JUST_RELEASE="$just_release" \
            --build-arg BUILD_DATE="$BUILD_DATE"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "just-$dist-$build_arch")"
        if ! docker cp "$id:/just_$FULL_VERSION.deb" - > "./just_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./just_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    # Clean up extracted directory
    rm -rf "$just_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Fetch the shared upstream changelog before building anything
if ! fetch_changelog; then
    exit 1
fi

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building just $JUST_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures
    ARCHITECTURES=("amd64" "arm64" "armel" "armhf" "riscv64" "loong64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la just_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
