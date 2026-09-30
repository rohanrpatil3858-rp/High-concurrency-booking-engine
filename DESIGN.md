# Design Notes

## Core entities
users, theatres, screens, seats, movies, shows, show_seats, bookings, booking_items, payments, payment_webhook_events.

## High concurrency
`show_seats` represents one physical seat for one show. `UNIQUE(show_id, seat_id)` prevents duplicate inventory. InnoDB transactions should lock requested rows using `SELECT ... FOR UPDATE`, check availability, create the hold/booking, and commit. A competing transaction waits and then sees the new state.

## Timed holds
A held seat has `status='HELD'` and `hold_expires_at`. An expiry worker releases expired holds. Redis can be used as a fast distributed hold/expiry layer in a production design.

## Idempotent webhooks
`payment_webhook_events.provider_event_id` is UNIQUE, so a provider retry cannot create a second record for the same event.

## Pessimistic vs optimistic locking
Pessimistic: `FOR UPDATE`; simple for hot seats but competing requests wait.
Optimistic: `version` column and `UPDATE ... WHERE version=?`; conflicts are detected by affected-row count.

## Indexing
Indexes cover show lookup by screen/date, show-seat status/expiry, bookings by user/show, booking items by seat, and webhook payment lookup.

## Normalization
1NF: atomic attributes/no repeating groups.
2NF: non-key attributes depend on their full key.
3NF: independent facts are separated and transitive dependencies avoided.
BCNF: relevant functional determinants are candidate keys, supported by primary/unique constraints such as theatre+screen name, screen+row+seat, and show+seat.

## Production extensions
Redis for distributed timed holds, a queue for burst handling, and a load test simulating many users competing for hot seats.
