# Agion — Firestore Data Schema

## Collection: `users` (document id = uid)

```json
{
  "uid": "string",
  "phone": "string",
  "joinDate": "timestamp",
  "level": "int",
  "xp": "int",
  "rank": "string",         // "E","D","C","B","A","S"
  "title": "string",
  "streak": "int",
  "lastActive": "timestamp",
  "settings": {
    "privacyTelemetry": false,
    "syncEnabled": true,
    "timezoneGrace": true
  }
}
```

## Subcollection: `users/{uid}/workouts`

```json
{
  "id": "string",
  "date": "timestamp",
  "duration": "int (seconds)",
  "exercises": [
    {
      "name": "string",
      "sets": [
        { "reps": "int", "weight": "float (kg)" }
      ]
    }
  ],
  "notes": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "synced": "bool"
}
```

## Subcollection: `users/{uid}/nutrition_logs`

```json
{
  "id": "string",
  "date": "timestamp",
  "foodId": "string (ref to foods collection)",
  "foodName": "string",
  "quantity": "float",
  "unit": "string (g, ml, piece)",
  "calories": "float",
  "protein": "float",
  "carbs": "float",
  "fat": "float",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "synced": "bool"
}
```

## Collection: `foods` (global, read-only for clients)

```json
{
  "id": "string",
  "name": "string",
  "calories": "float (per 100g or per piece as noted)",
  "protein": "float",
  "carbs": "float",
  "fat": "float",
  "tags": ["string"],
  "region": "in"
}
```

Seed from `assets/foods/foods_in_seed.csv` via Cloud Function or admin script.

## Collection: `audit` (optional)

```json
{
  "userId": "string (hashed)",
  "action": "string",
  "timestamp": "timestamp"
}
```

Rotate monthly. Keep minimal.

## Sync Strategy

1. Local writes → local Hive DB + append to `PendingSyncQueue`
2. `SyncService` attempts background sync (exponential backoff)
3. Conflict resolution: compare `updatedAt`; local wins if newer
4. Fields `synced: true/false` track individual document sync status
