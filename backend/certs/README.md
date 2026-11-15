# Supabase development trust anchor

Save the public server root certificate downloaded through the project's authenticated Supabase Database Settings as `supabase-root.crt` in this directory. Use PEM format. Do not download a private key or an unverified certificate from the database handshake.

The database client adds this authority only for Supabase hosts and keeps hostname/certificate verification enabled. System roots remain enabled. Missing/invalid trust fails closed; do not use SSL verification bypasses. `DATABASE_CA_FILE` can explicitly select a different reviewed CA file.

The coordinator records the certificate's SHA-256 fingerprint, issuer and expiry after verifying its dashboard provenance. This public certificate can be committed for the five developers; no password or service-account key belongs here.

Reference: https://supabase.com/docs/guides/database/psql
