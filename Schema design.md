# Schema design

## Use cases

* Create a record
  * Incomes
    * date
    * amount
    * property
    * category
    * memo
  * Expenses
    * date
    * amount
    * property
    * category
    * memo
  * Transfer
    * date
    * amount
    * property (from)
    * property (to)
    * memo
* View records(daily)
  * Expenses
    * Category
    * memo
    * Amount
  * Expenses
    * Category
    * memo
    * Amount
  * Transfers
    * Property (from)
    * Property (to)
    * memo
    * Amount
* View records(monthly)
  * Total income amount per day
  * Total expense amount per day
* Edit a record
* Delete a record
* Create a property
  * Name
  * Current value
* View properties
  * name
  * current value
* Edit a property
* Delete a property
* Create a category
  * name
* View categories
  * name
* Edit a category
* Delete a category
* Register a user
* Delete a user
* Update a user info
  * PUBLIC user name
* Register a pair
* Delete a pair

## Documents

### /publicProfiles/{uid}

This document contains public profile information of the user. This document relates to use cases:
register a user, register a pair.

This document is created with batch at the same moment when personal note of the user is created.
`createdAt` is used in verification of the batch operations. What is `updatedAt` used for?

* Allow everyone to read.
  * Relates to "register a pair".
* Allow the user to update.
  * Relates to "update a user info".
* Created by Admin SDK.
  * Relates to "register a user".

```text
<uid>: {
  name: string,
  updatedAt: timestamp,
  createdAt: timestamp.
}
```

### /personalNotes/{uid}

This document and sub-collections can only be read and/or written by the user. This document relates
to use cases: register a user.

This document is created with batch at the same moment when public information of the user is
created.
`createdAt` is used in verification of the batch operations.

* Allow the user to read.
  * Relates to "register a user".
* Created by Admin SDK.
  * Relates to "register a user".

```text
<uid>: {
  createdAt: timestamp
}
```

### /personalNotes/{uid}/categories/{category-id}

This document contains information of the category. This document relates to use cases:
create/view/edit/delete category(categories).

`type` is one of `income` or `expense`.
`name` is used to sort on display.

* Allow the user to read(get and list).
  * Relates to "view categories".
* Allow the user to write(create, update and delete).
  * Relates to "create/edit/delete a category"

```text
<category-id>: {
  name: string,
  type: string
}
```

### /personalNotes/{uid}/properties/{property-id}

This document contains information of the property. This document relates to use cases:
create/view/edit/delete property(properties).

`name` is used to sort on display.

* Allow the user to read(get and list).
  * Relates to "view properties".
* Allow the user to write(create, update and delete).
  * Relates to "create/edit/delete a property"

```text
<property-id>: {
  name: string,
  amount: integer
}
```

**WIP FROM HERE TO THE BOTTOM**

### /personalNotes/{uid}/calendars/{calendar-id}

What is a trigger to create this document? Changes of months, the first creation of record in the
month, or... what?

This document is a summary on a monthly basis. This document relates to use cases: view records(
monthly), create/edit/delete a record.

`incomes` and `expenses` are updated in transaction.
`updatedAt` is used in verification of transactions.

```text
<calendar-id>: {
  year: integer,
  month: integer,
  daysInMonth: integer,
  incomes: Map<int, int> // keys are 1-31, and values are total incomes of the day.
  expenses: Map<int, int> // keys are 1-31, and values are total expenses of the day.
  updatedAt: timestamp
}
```

### /personalNotes/{uid}/calendars/{calendar-id}/incomeRecords/{record-id}

`updatedAt` is used in verification of transactions.
`createdAt` is used to sort.

```text
<record-id>: {
  year: integer,
  month: integer,
  day: integer,
  type: string (fixed to "income")
  amount: integer,
  property: {
    ref: reference to property
  },
  category: {
    ref: reference to category
  },
  memo: string,
  updatedAt: timestamp,
  createdAt: timestamp
}
```

### /personalNotes/{uid}/calendars/{calendar-id}/expenseRecords/{record-id}

`updatedAt` is used in verification of transactions.
`createdAt` is used to sort.

```text
<record-id>: {
  year: integer,
  month: integer,
  day: integer,
  type: string (fixed to "expense")
  amount: integer,
  property: {
    ref: reference to property
  },
  category: {
    ref: reference to category
  },
  memo: string,
  updatedAt: timestamp,
  createdAt: timestamp
}
```

### /personalNotes/{uid}/calendars/{calendar-id}/transferRecords/{record-id}

`updatedAt` is used in verification of transactions.
`createdAt` is used to sort.

```text
<record-id>: {
  year: integer,
  month: integer,
  day: integer,
  type: string (fixed to "transfer")
  amount: integer,
  fromProperty: {
    ref: reference to property
  },
  toProperty: {
    ref: reference to property
  },
  memo: string,
  updatedAt: timestamp,
  createdAt: timestamp
}
```

### /notes/{note-id}

This document contains general information of the note. This document relates to use cases: use
registration and pair.

When a new user is registered or two users becomes a pair, this document is automatically created by
admin SDK.

* Allow the owners to read(only get).
* Allow admin SDK to create.

```text
<note-id>: {
  owners: Array of references to users that own this note. This length of array is one or two,
  createdAt: timestamp
}
```

### /notes/{note-id}/categories/{category-id}

This document contains information of the category. This document relates to use cases:
create/view/edit/delete category(categories).

`type` is one of `income` or `expense`.
`name` is used to sort on display.

* Allow the owners to read(get and list).
* Allow the owners to write(create, update and delete).

```text
<category-id>: {
  name: string,
  type: string
}
```

### /notes/{note-id}/properties/{property-id}

This document contains information of the property. This document relates to use cases:
create/view/edit/delete property(properties).

`name` is used to sort on display.

* Allow the owners to read(get and list).
* Allow the owners to write(create, update and delete).

```text
<property-id>: {
  name: string,
  amount: integer
}
```

### /notes/{note-id}/calendars/{calendar-id}

`incomes` and `expenses` are updated in transaction.
`updatedAt` is used in verification of transactions.

```text
<calendar-id>: {
  year: integer,
  month: integer,
  daysInMonth: integer,
  incomes: Map<int, int> // keys are 1-31, and values are total incomes of the day.
  expenses: Map<int, int> // keys are 1-31, and values are total expenses of the day.
  updatedAt: timestamp
}
```

### /notes/{note-id}/calendars/{calendar-id}/incomeRecords/{record-id}

`updatedAt` is used in verification of transactions.
`createdAt` is used to sort.

```text
<record-id>: {
  year: integer,
  month: integer,
  day: integer,
  type: string (fixed to "income")
  amount: integer,
  property: {
    ref: reference to property
  },
  category: {
    ref: reference to category
  },
  memo: string,
  updatedAt: timestamp,
  createdAt: timestamp
}
```

### /notes/{note-id}/calendars/{calendar-id}/expenseRecords/{record-id}

`updatedAt` is used in verification of transactions.
`createdAt` is used to sort.

```text
<record-id>: {
  year: integer,
  month: integer,
  day: integer,
  type: string (fixed to "expense")
  amount: integer,
  property: {
    ref: reference to property
  },
  category: {
    ref: reference to category
  },
  memo: string,
  updatedAt: timestamp,
  createdAt: timestamp
}
```

### /notes/{note-id}/calendars/{calendar-id}/transferRecords/{record-id}

`updatedAt` is used in verification of transactions.
`createdAt` is used to sort.

```text
<record-id>: {
  year: integer,
  month: integer,
  day: integer,
  type: string (fixed to "transfer")
  amount: integer,
  fromProperty: {
    ref: reference to property
  },
  toProperty: {
    ref: reference to property
  },
  memo: string,
  updatedAt: timestamp,
  createdAt: timestamp
}
```
