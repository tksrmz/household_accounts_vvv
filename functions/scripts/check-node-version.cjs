"use strict";

const { devEngines, engines } = require("../package.json");

const requiredVersion = engines?.node;
const requiredMajorMatch = /^(\d+)(?:\.x)?$/.exec(requiredVersion ?? "");
const supportedVersion = devEngines?.runtime?.version;
const supportedVersionMatch =
  /^>=(\d+)\.(\d+)\.(\d+) <(\d+)$/.exec(supportedVersion ?? "");

if (!requiredMajorMatch || !supportedVersionMatch) {
  console.error(
    "Unsupported Node.js version configuration: " +
      `engines.node=${requiredVersion}, ` +
      `devEngines.runtime.version=${supportedVersion}`,
  );
  process.exit(1);
}

const requiredMajor = Number(requiredMajorMatch[1]);
const minimumVersion = supportedVersionMatch.slice(1, 4).map(Number);
const maximumMajor = Number(supportedVersionMatch[4]);
const actualVersion = process.versions.node;
const actual = actualVersion.split(".").map(Number);
const isAtLeastMinimum = actual.some((part, index) =>
  part > minimumVersion[index] &&
  actual.slice(0, index).every((value, partIndex) =>
    value === minimumVersion[partIndex]
  )
) || actual.every((part, index) => part === minimumVersion[index]);

if (
  minimumVersion[0] !== requiredMajor ||
  maximumMajor !== requiredMajor + 1 ||
  actual[0] !== requiredMajor ||
  !isAtLeastMinimum
) {
  console.error(
    `Node.js ${supportedVersion} is required; current version is ${actualVersion}.`,
  );
  process.exit(1);
}
