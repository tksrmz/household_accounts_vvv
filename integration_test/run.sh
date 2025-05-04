#!/bin/bash

# Setup
echo "integration_test/run: Setup"
cd "$(dirname "$0")"
pwd

# Launch
echo "integration_test/run: Run integration tests"
cd ..
pwd
flutter test integration_test/integration_test.dart
