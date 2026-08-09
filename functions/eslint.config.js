const js = require("@eslint/js");
const { defineConfig, globalIgnores } = require("eslint/config");
const globals = require("globals");
const tsPlugin = require("@typescript-eslint/eslint-plugin");

const commonJsFiles = ["**/*.{js,cjs}"];
const jsFiles = [...commonJsFiles, "**/*.mjs"];
const tsFiles = ["**/*.{ts,cts,mts}"];
const sourceFiles = [...jsFiles, ...tsFiles];

module.exports = defineConfig([
  globalIgnores(["lib/**"]),
  {
    name: "functions/recommended",
    files: sourceFiles,
    extends: [js.configs.recommended],
    languageOptions: {
      globals: globals.node,
    },
  },
  {
    name: "functions/commonjs",
    files: commonJsFiles,
    languageOptions: {
      sourceType: "commonjs",
    },
  },
  {
    name: "functions/typescript",
    files: tsFiles,
    extends: [tsPlugin.configs["flat/recommended"]],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
    },
  },
  {
    name: "functions/style",
    files: sourceFiles,
    rules: {
      "quotes": ["error", "double"],
      "indent": ["error", 2],
      "object-curly-spacing": ["error", "always"],
      "max-len": ["error", {
        code: 80,
        ignoreComments: true,
        ignoreStrings: true,
        ignoreTemplateLiterals: true,
      }],
    },
  },
]);
