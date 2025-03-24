#!/bin/bash

# Setup
echo "run_integration_test: Setup"
cd "$(dirname "$0")"
pwd

# Launch
echo "run_integration_test: Run integration tests"
cd ../..
pwd
flutter test integration_test/launching_app_test.dart
