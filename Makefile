# Classio Flutter Project Makefile
# Usage: make <target>

.PHONY: help install clean build-runner analyze format test test-coverage \
        build-web build-android build-ios run-web run-android gen-l10n \
        update-deps check-outdated ci deploy-web

# Default target
help:
	@echo "Classio Flutter Project - Available Commands"
	@echo "============================================="
	@echo ""
	@echo "Setup & Dependencies:"
	@echo "  make install        - Install Flutter dependencies"
	@echo "  make update-deps    - Update dependencies"
	@echo "  make check-outdated - Check for outdated packages"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "Code Generation:"
	@echo "  make build-runner   - Run build_runner for code generation"
	@echo "  make gen-l10n       - Generate localization files"
	@echo ""
	@echo "Code Quality:"
	@echo "  make analyze        - Run Flutter analyzer"
	@echo "  make format         - Format all Dart code"
	@echo "  make format-check   - Check formatting without changes"
	@echo "  make lint           - Run analyze + format-check"
	@echo ""
	@echo "Testing:"
	@echo "  make test           - Run all tests"
	@echo "  make test-coverage  - Run tests with coverage"
	@echo ""
	@echo "Building:"
	@echo "  make build-web      - Build web release"
	@echo "  make build-android  - Build Android APK"
	@echo "  make build-ios      - Build iOS (macOS only)"
	@echo ""
	@echo "Running:"
	@echo "  make run-web        - Run web in debug mode"
	@echo "  make run-android    - Run on Android"
	@echo ""
	@echo "CI/CD:"
	@echo "  make ci             - Run all CI checks locally"
	@echo "  make deploy-web     - Deploy to Firebase Hosting"

# Setup
install:
	@echo "Installing dependencies..."
	flutter pub get

update-deps:
	@echo "Updating dependencies..."
	flutter pub upgrade --major-versions

check-outdated:
	@echo "Checking for outdated packages..."
	flutter pub outdated

clean:
	@echo "Cleaning build artifacts..."
	flutter clean
	rm -rf coverage/
	rm -rf build/

# Code Generation
build-runner:
	@echo "Running build_runner..."
	dart run build_runner build --delete-conflicting-outputs

gen-l10n:
	@echo "Generating localization files..."
	flutter gen-l10n

# Code Quality
analyze:
	@echo "Running Flutter analyzer..."
	flutter analyze --no-pub

format:
	@echo "Formatting Dart code..."
	dart format .

format-check:
	@echo "Checking code formatting..."
	dart format --output=none --set-exit-if-changed .

lint: analyze format-check
	@echo "All lint checks passed!"

# Testing
test:
	@echo "Running tests..."
	flutter test

test-coverage:
	@echo "Running tests with coverage..."
	flutter test --coverage
	@echo "Coverage report: coverage/lcov.info"

# Building
build-web:
	@echo "Building web release..."
	flutter build web --release

build-android:
	@echo "Building Android APK..."
	flutter build apk --release

build-ios:
	@echo "Building iOS..."
	flutter build ios --release --no-codesign

# Running
run-web:
	@echo "Running web..."
	flutter run -d chrome

run-android:
	@echo "Running on Android..."
	flutter run -d android

# CI/CD
ci: install build-runner format-check analyze test
	@echo ""
	@echo "============================================="
	@echo "All CI checks passed!"
	@echo "============================================="

deploy-web:
	@echo "Deploying to Firebase Hosting..."
	@if [ ! -d "build/web" ]; then \
		echo "Error: build/web not found. Run 'make build-web' first."; \
		exit 1; \
	fi
	firebase deploy --only hosting
