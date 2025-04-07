#!/bin/bash

set -e

# Set HOME to /root to avoid errors in
# bun install.
HOME=/root
export HOME

dnf install -y unzip

curl -fsSL https://bun.sh/install | bash -s "bun-v1.2.8"

ln -s /root/.bun/bin/bun /usr/local/bin/bun
ln -s /root/.bun/bin/bunx /usr/local/bin/bunx

cd /home/ec2-user

mkdir app
cd app

cat <<'EOF' > .env
DB_HOST=${db_host}
DB_USER=${db_username}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}
EOF

# Taken from https://bun.sh/guides/ecosystem/drizzle

bun init -y
bun add drizzle-orm@0.41.0 mysql2@3.14.0
bun add -D drizzle-kit@0.30.6

cat <<'EOF' > drizzle.config.ts
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  dialect: "mysql",
  schema: "./src/schema.ts",
  out: "./drizzle",

  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});
EOF

cat <<'EOF' > schema.ts
import { int, mysqlTable, serial, varchar } from 'drizzle-orm/mysql-core';

export const movies = mysqlTable("movies", {
  id: serial().primaryKey(),
  title: varchar({ length: 255 }).notNull(),
  releaseYear: int().notNull(),
});
EOF

bunx drizzle-kit generate --dialect mysql --schema ./schema.ts

# NOTE: This is only here because Drizzle has a bug where generated
# migrations for MySQL are not idempotent. YMMV.
# https://github.com/drizzle-team/drizzle-orm/issues/2815

# shellcheck disable=SC2016
sed -i 's/CREATE TABLE `movies`/CREATE TABLE IF NOT EXISTS `movies`/g' ./drizzle/*.sql

cat <<'EOF' > db.ts
import { drizzle } from "drizzle-orm/mysql2";
import * as schema from "./schema";

export const db = drizzle({ schema, mode: "default", connection: {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
}});
EOF

cat <<'EOF' > migrate.ts
import { migrate } from "drizzle-orm/mysql2/migrator";
import { db } from "./db";

await migrate(db, { migrationsFolder: "./drizzle" });
process.exit();
EOF

bun run migrate.ts

cat <<'EOF' > seed.ts
import { db } from "./db";
import * as schema from "./schema";
import { sql } from "drizzle-orm";

const movies = await db.query.movies.findMany();

if (movies.length > 0) {
  console.log(`Movies table already seeded. Skipping...`);
  process.exit();
}

await db.insert(schema.movies).values([
  {
    id: 1,
    title: "The Matrix",
    releaseYear: 1999,
  },
  {
    id: 2,
    title: "The Matrix Reloaded",
    releaseYear: 2003,
  },
  {
    id: 3,
    title: "The Matrix Revolutions",
    releaseYear: 2003,
  },
])
.onDuplicateKeyUpdate({
  set: { id: sql`id` },
});

console.log(`Seeding complete.`);
process.exit();
EOF

bun run seed.ts

cat <<'EOF' > index.ts
import * as schema from "./schema";
import { db } from "./db";
import { eq } from "drizzle-orm";

Bun.serve({
  routes: {
    "/": new Response("OK"),

    "/movies": async () => {
      const result = await db.query.movies.findMany();
      return Response.json(result);
    },

    "/movies/:id": async req => {
      const id = req.params.id;
      const movie = await db.query.movies.findFirst({ where: eq(schema.movies.id, id) });
      return Response.json(movie);
    },
  },

  fetch(req) {
    return new Response("Not Found", { status: 404 });
  },
})
EOF

nohup bun run index.ts &
