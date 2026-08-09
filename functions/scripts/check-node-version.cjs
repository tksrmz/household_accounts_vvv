"use strict";

const {engines} = require("../package.json");

const requiredVersion = engines?.node;
const requiredMajorMatch = /^(\d+)(?:\.x)?$/.exec(requiredVersion ?? "");

if (!requiredMajorMatch) {
  console.error(
    `Unsupported engines.node value for the runtime check: ${requiredVersion}`,
  );
  process.exit(1);
}

const requiredMajor = Number(requiredMajorMatch[1]);
const actualVersion = process.versions.node;
const actualMajor = Number(actualVersion.split(".")[0]);

if (actualMajor !== requiredMajor) {
  console.error(
    `Node.js ${requiredMajor}.x is required; current version is ${actualVersion}.`,
  );
  process.exit(1);
}
