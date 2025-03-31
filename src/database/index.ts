import { type InsertObject, Kysely } from 'kysely'
import { PostgresJSDialect } from 'kysely-postgres-js'
import postgres from 'postgres'
import { logger } from '#/logger'
import fs from 'fs'

import { env } from '#/env.ts'
import type { DB } from './generated/index.ts'

export type Row<T extends keyof DB> = InsertObject<DB, T>

logger.info(`⏳ DATABASE_URL ${env.DATABASE_URL}`)
logger.info(`⏳ DATABASE_URL ${env.DATABASE_SSL_FILE}`)

export const postgresClient = postgres(env.DATABASE_URL, {
  ssl: {
    rejectUnauthorized: false, // Disable certificate validation (use carefully and avoid in production)
    ca: fs.readFileSync(env.DATABASE_SSL_FILE).toString(), // Load root certificate if needed
  }
})

export const database = new Kysely<DB>({
  dialect: new PostgresJSDialect({
    postgres: postgresClient
  }),
  log: (event) => {
    if (event.level === 'query') {
      console.log(`Executing query: ${event.query}`)
    }
  }
})