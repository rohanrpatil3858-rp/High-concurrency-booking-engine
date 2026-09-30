# Demo checklist (about 2 minutes)

1. Open MySQL Workbench and show Local instance MySQL80.
2. Open `sql/schema.sql`.
3. Execute it.
4. Show `bookmyshow_db` and its tables.
5. Run/show the P2 query result.
6. Explain in one sentence each:
   - show_seats + UNIQUE(show_id,seat_id) prevents duplicate seat inventory.
   - FOR UPDATE serializes competing updates to the same seat rows.
   - hold_expires_at supports timed holds.
   - UNIQUE(provider_event_id) makes webhook handling idempotent.
7. Stop recording.
