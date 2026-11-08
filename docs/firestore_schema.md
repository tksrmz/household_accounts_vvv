# Firestore Schema for Household Accounts

このドキュメントは、家計簿アプリのFirestoreデータベーススキーマを定義しています。

## JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Household Accounts Firebase Schema",
  "description": "JSON Schema for Household Accounts Firebase database",
  "definitions": {
    "Record": {
      "type": "object",
      "required": ["date", "amount", "note", "createdAt", "hasCheckedOut", "type"],
      "properties": {
        "date": {
          "type": "string",
          "format": "date-time",
          "description": "Timestamp of the record"
        },
        "amount": {
          "type": "integer",
          "minimum": 1,
          "description": "Amount value (must be 1 or greater)"
        },
        "note": {
          "type": "string",
          "maxLength": 100,
          "description": "Note about the record"
        },
        "createdAt": {
          "type": "string",
          "format": "date-time",
          "description": "Timestamp when the record was created"
        },
        "hasCheckedOut": {
          "type": "boolean",
          "description": "Whether the record has been checked out"
        },
        "type": {
          "type": "string",
          "enum": ["income", "expense", "transfer"],
          "description": "Type of the record"
        }
      }
    },
    
    "IncomeRecord": {
      "allOf": [
        { "$ref": "#/definitions/Record" },
        {
          "properties": {
            "type": {
              "const": "income"
            },
            "property": {
              "type": "object",
              "required": ["ref"],
              "properties": {
                "ref": {
                  "type": "DocumentReference",
                  "description": "DocumentReference to a property"
                }
              }
            },
            "category": {
              "type": "object",
              "required": ["ref"],
              "properties": {
                "ref": {
                  "type": "DocumentReference",
                  "description": "DocumentReference to a category"
                }
              }
            }
          },
          "required": ["property", "category"]
        }
      ]
    },

    "ExpenseRecord": {
      "allOf": [
        { "$ref": "#/definitions/Record" },
        {
          "properties": {
            "type": {
              "const": "expense"
            },
            "property": {
              "type": "object",
              "required": ["ref"],
              "properties": {
                "ref": {
                  "type": "DocumentReference",
                  "description": "DocumentReference to a property"
                }
              }
            },
            "category": {
              "type": "object",
              "required": ["ref"],
              "properties": {
                "ref": {
                  "type": "DocumentReference",
                  "description": "DocumentReference to a category"
                }
              }
            }
          },
          "required": ["property", "category"]
        }
      ]
    },
    
    "TransferRecord": {
      "allOf": [
        { "$ref": "#/definitions/Record" },
        {
          "properties": {
            "type": {
              "const": "transfer"
            },
            "fromProperty": {
              "type": "object",
              "required": ["ref"],
              "properties": {
                "ref": {
                  "type": "DocumentReference",
                  "description": "DocumentReference to source property"
                }
              }
            },
            "toProperty": {
              "type": "object",
              "required": ["ref"],
              "properties": {
                "ref": {
                  "type": "DocumentReference",
                  "description": "DocumentReference to destination property"
                }
              }
            }
          },
          "required": ["fromProperty", "toProperty"]
        }
      ]
    },
    
    "IncomeCategory": {
      "type": "object",
      "required": ["name", "type"],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 20,
          "description": "Category name"
        },
        "type": {
          "const": "income",
          "description": "Category type"
        }
      }
    },
    
    "ExpenseCategory": {
      "type": "object",
      "required": ["name", "type", "totalBudget"],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 20,
          "description": "Category name"
        },
        "type": {
          "const": "expense",
          "description": "Category type"
        },
        "totalBudget": {
          "type": "integer",
          "minimum": 0,
          "description": "Total budget for this expense category"
        }
      }
    },

    "Property": {
      "type": "object",
      "required": ["name", "amount"],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 20,
          "description": "Property name"
        },
        "amount": {
          "type": "integer",
          "description": "Current amount in the property"
        }
      }
    },

    "PublicProfile": {
      "type": "object",
      "required": ["name", "createdAt", "updatedAt"],
      "properties": {
        "name": {
          "type": "string",
          "minLength": 1,
          "maxLength": 20,
          "description": "User's public name"
        },
        "createdAt": {
          "type": "string",
          "format": "date-time",
          "description": "Timestamp when the record was created"
        },
        "updatedAt": {
          "type": "string",
          "format": "date-time",
          "description": "Timestamp when the record was updated"
        }
      }
    },

    "PrivateProfile": {
      "type": "object",
      "description": "User's private profile information",
      "properties": {
        "sharedNote": {
          "type": "object",
          "required": ["ref"],
          "properties": {
            "ref": {
              "type": "string",
              "description": "Reference path to shared note"
            }
          }
        }
      }
    }
  },

  "type": "object",
  "properties": {
    "Collection:publicProfiles": {
      "type": "object",
      "patternProperties": {
        "^.*$": {
          "$ref": "#/definitions/PublicProfile"
        }
      },
      "description": "Collection of public user profiles"
    },

    "Collection:privateProfiles": {
      "type": "object",
      "patternProperties": {
        "^.*$": {
          "$ref": "#/definitions/PrivateProfile"
        }
      },
      "description": "Collection of private user profiles"
    },

    "Collection:personalNotes": {
      "type": "object",
      "patternProperties": {
        "^.*$": {
          "type": "object",
          "properties": {
            "Collection:incomeCategories": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/IncomeCategory"
                }
              },
              "description": "Collection of income categories"
            },
            "Collection:expenseCategories": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/ExpenseCategory"
                }
              },
              "description": "Collection of expense categories"
            },
            "Collection:properties": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/Property"
                }
              },
              "description": "Collection of properties"
            },
            "Collection:incomes": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/IncomeRecord"
                }
              },
              "description": "Collection of income records"
            },
            "Collection:expenses": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/ExpenseRecord"
                }
              },
              "description": "Collection of expense records"
            },
            "Collection:transfers": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/TransferRecord"
                }
              },
              "description": "Collection of transfer records"
            }
          },
          "description": "Personal notes for a user"
        }
      },
      "description": "Collection of personal notes"
    },
    
    "Collection:sharedNotes": {
      "type": "object",
      "patternProperties": {
        "^.*$": {
          "type": "object",
          "properties": {
            "owners": {
              "type": "array",
              "items": {
                "type": "string"
              },
              "description": "List of user IDs who own this shared note"
            },
            "Collection:incomeCategories": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/IncomeCategory"
                }
              },
              "description": "Collection of income categories"
            },
            "Collection:expenseCategories": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/ExpenseCategory"
                }
              },
              "description": "Collection of expense categories"
            },
            "Collection:properties": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/Property"
                }
              },
              "description": "Collection of properties"
            },
            "Collection:incomes": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/IncomeRecord"
                }
              },
              "description": "Collection of income records"
            },
            "Collection:expenses": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/ExpenseRecord"
                }
              },
              "description": "Collection of expense records"
            },
            "Collection:transfers": {
              "type": "object",
              "patternProperties": {
                "^.*$": {
                  "$ref": "#/definitions/TransferRecord"
                }
              },
              "description": "Collection of transfer records"
            }
          },
          "description": "Shared notes between paired users"
        }
      },
      "description": "Collection of shared notes"
    }
  }
}
```

## スキーマの説明

このJSONスキーマは、家計簿アプリのFirestoreデータベース構造を表現しています。主要なコレクションとドキュメント構造は以下の通りです：

### 主要なドキュメント型

1. **Record（記録）**
   - 基本的な記録型で、income（収入）、expense（支出）、transfer（振替）の3種類があります
   - 共通フィールド: date, amount, note, createdAt, hasCheckedOut, type
   - タイプ別の特有フィールド:
     - income/expense: property, category
     - transfer: fromProperty, toProperty

2. **Category（カテゴリ）**
   - income（収入）とexpense（支出）の2種類
   - 支出カテゴリには予算（totalBudget）が設定可能

3. **Property（資産）**
   - 名前と金額を持つ資産を表現

4. **Profile（プロフィール）**
   - 公開プロフィール（publicProfiles）と非公開プロフィール（privateProfiles）

### コレクション構造

- **publicProfiles**: ユーザーの公開プロフィール
- **privateProfiles**: ユーザーの非公開プロフィール情報
- **personalNotes**: 個人の家計簿データ
  - incomeCategories: 収入カテゴリ
  - expenseCategories: 支出カテゴリ
  - properties: 資産
  - incomes: 収入記録
  - expenses: 支出記録
  - transfers: 振替記録
- **sharedNotes**: 共有家計簿データ
  - incomeCategories: 共有収入カテゴリ
  - expenseCategories: 共有支出カテゴリ
  - properties: 共有資産
  - incomes: 共有収入記録
  - expenses: 共有支出記録
  - transfers: 共有振替記録

このスキーマは、Firestoreのセキュリティルールに基づいて作成されており、データベースの構造と各フィールドの制約を表現しています。
