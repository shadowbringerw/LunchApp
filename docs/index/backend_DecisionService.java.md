# backend/src/main/java/com/kunlunlunch/decision/DecisionService.java

## Overview
Service layer handling the logic for picking a lunch option. Implements a weighted random algorithm that penalizes recently chosen options.

## Key Methods

### `decide(List<String> rawOptions)`
1. **Clean Input:** Trims and filters empty/duplicate options.
2. **Fetch History:** Gets the last 3 decisions from `DecisionRecordRepository`.
3. **Identify Penalties:** Finds options that have been chosen at least twice in the last 3 times (`repeatedChoices`).
4. **Weighted Pick:**
   - Normal options: Weight 1.0.
   - Penalized options: Weight 0.5.
   - Uses `Random` to pick based on weights.
5. **Save & Return:** Saves the new decision and returns the result.

### `history(int limit)`
- Returns a list of past decisions, ordered by time descending.

### `clearHistory()`
- Deletes all records from the database.

### `weightedPick` (Private)
- Standard weighted random selection algorithm.

### `repeatedChoices` (Private)
- Logic: If an item appears >= 2 times in the input list (recent history), it is marked for penalty.
