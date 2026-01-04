freeze:
# 	dart run build_runner build
# 	flutter pub run build_runner build
	dart run build_runner build --delete-conflicting-outputs


apk:
	flutter build apk

appBundle:
	flutter build appbundle

# Development commands
install:
	flutter pub get

clean:
	flutter clean
	flutter pub get

format:
	dart format lib/ test/

lint:
	flutter analyze

fix:
	dart fix --apply

# Testing commands
test:
	flutter test

test-coverage:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html
	open coverage/html/index.html

# Running commands
run:
	flutter run

run-debug:
	flutter run --debug

run-release:
	flutter run --release

run-profile:
	flutter run --profile

# Building for different platforms
build-ios:
	flutter build ios

build-web:
	flutter build web

build-windows:
	flutter build windows

build-macos:
	flutter build macos

build-linux:
	flutter build linux

# Cleaning specific platforms
clean-ios:
	flutter clean
	cd ios && rm -rf Pods Podfile.lock && pod install

clean-android:
	flutter clean
	cd android && ./gradlew clean

# Utility commands
doctor:
	flutter doctor

devices:
	flutter devices

upgrade:
	flutter upgrade

pub-upgrade:
	flutter pub upgrade

# Combined workflows
setup: clean install

pretty: format lint

build-all: apk appBundle build-ios build-web

# Watch mode for development
watch:
	flutter run --hot

# Generate assets/icons
generate-icons:
	flutter pub run flutter_launcher_icons:main

generate-splash:
	flutter pub run flutter_native_splash:create

# Dependency management
pub-deps:
	flutter pub deps

pub-outdated:
	flutter pub outdated

# Performance profiling
profile:
	flutter run --profile --trace-startup

# Help command
help:
	@echo "Available commands:"
	@echo "  freeze           - Freeze dependencies"
	@echo "  apk              - Build apk"
	@echo "  appBundle        - Build app bundle"
	@echo "  install          - Install dependencies"
	@echo "  clean            - Clean build files and reinstall dependencies"
	@echo "  format           - Format code"
	@echo "  lint             - Run code analysis"
	@echo "  fix              - Apply automatic fixes"
	@echo "  test             - Run tests"
	@echo "  test-coverage    - Run tests with coverage report"
	@echo "  run              - Run app in debug mode"
	@echo "  run-release      - Run app in release mode"
	@echo "  build-all        - Build for all platforms"
	@echo "  doctor           - Check Flutter installation"
	@echo "  setup            - Clean and install (fresh start)"
	@echo "  pretty           - Format and lint code"

.PHONY: freeze apk appBundle install clean format lint fix test test-coverage run run-debug run-release run-profile build-ios build-web build-windows build-macos build-linux clean-ios clean-android doctor devices upgrade pub-upgrade setup pretty build-all watch generate-icons generate-splash pub-deps pub-outdated profile help