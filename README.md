# High-Concurrency Booking Engine

MySQL 8.0 database solution for the BookMyShow-style assignment.

## Run
1. Open MySQL Workbench.
2. Connect to Local instance MySQL80.
3. Open `sql/schema.sql`.
4. Execute it.
5. Verify with `USE bookmyshow_db; SHOW TABLES;`.

## Included
- Normalized entities/tables
- Sample data
- P2 theatre/date show query
- Indexes
- Seat-level concurrency design
- Pessimistic locking with `SELECT ... FOR UPDATE`
- Timed holds using `hold_expires_at`
- Idempotent payment webhook storage using `UNIQUE(provider_event_id)`
- Optimistic locking `version` field

The assignment submission guidelines explicitly require MySQL-executable SQL and a document/PDF. A full Java/Python application is not required for the stated P1/P2 deliverables.
