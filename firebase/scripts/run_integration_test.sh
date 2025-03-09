#!/bin/bash

# Setup
echo "Setup"
cd "$(dirname "$0")"
pwd

# Launch
echo "Running integration tests"
cd ../..
pwd
flutter test integration_test/launching_app_test.dart
