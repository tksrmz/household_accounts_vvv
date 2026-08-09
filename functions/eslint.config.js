const tsPlugin = require("@typescript-eslint/eslint-plugin");
const tsParser = require("@typescript-eslint/parser");

module.exports = [
  {
    ignores: ["lib/**", "node_modules/**"],
  },
  {
    files: ["**/*.ts"],
    languageOptions: {
      parser: tsParser,
      ecmaVersion: 2022,
      sourceType: "module",
      globals: {
        process: "readonly",
        console: "readonly",
        module: "readonly",
        require: "readonly",
        __dirname: "readonly",
        __filename: "readonly",
      },
    },
    plugins: {
      "@typescript-eslint": tsPlugin,
    },
    rules: {
      ...tsPlugin.configs.recommended.rules,
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
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "commonjs",
      globals: {
        process: "readonly",
        console: "readonly",
        module: "readonly",
        require: "readonly",
        __dirname: "readonly",
        __filename: "readonly",
      },
    },
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
];
