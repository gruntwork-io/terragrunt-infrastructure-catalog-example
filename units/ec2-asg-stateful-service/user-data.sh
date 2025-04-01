#!/usr/bin/env bash

set -euo pipefail

dnf install -y unzip-6.0-57.amzn2023.0.2.aarch64

curl -fsSL https://bun.sh/install | bash -s "bun-v1.2.8"

PATH="$HOME/.bun/bin:$PATH"
export PATH

mkdir app
cd app

# Taken from https://bun.sh/guides/ecosystem/drizzle

bun init -y
bun add drizzle-orm@0.41.0
bun add -D drizzle-kit@0.30.6

cat <<'EOF' > schema.ts
import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";

export const movies = sqliteTable("movies", {
  id: integer("id").primaryKey(),
  title: text("name"),
  releaseYear: integer("release_year"),
});
EOF

bunx drizzle-kit generate --dialect sqlite --schema ./schema.ts

cat <<'EOF' > db.ts
import { drizzle } from "drizzle-orm/bun-sqlite";
import { Database } from "bun:sqlite";
import * as schema from "./schema";

const sqlite = new Database("sqlite.db");
export const db = drizzle({ client: sqlite , schema: schema });
EOF

cat <<'EOF' > migrate.ts
import { migrate } from "drizzle-orm/bun-sqlite/migrator";
import { db } from "./db";

migrate(db, { migrationsFolder: "./drizzle" });
EOF

bun run migrate.ts

cat <<'EOF' > seed.ts
import { db } from "./db";
import * as schema from "./schema";

await db.insert(schema.movies).values([
  {
    title: "The Matrix",
    releaseYear: 1999,
  },
  {
    title: "The Matrix Reloaded",
    releaseYear: 2003,
  },
  {
    title: "The Matrix Revolutions",
    releaseYear: 2003,
  },
]);

console.log(`Seeding complete.`);
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

bun run index.ts
