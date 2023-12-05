import type { ColumnType } from 'kysely'

export type Generated<T> = T extends ColumnType<infer S, infer I, infer U>
  ? ColumnType<S, I | undefined, U>
  : ColumnType<T, T | undefined, T>

export type Int8 = ColumnType<string, bigint | number | string, bigint | number | string>

export type Json = ColumnType<JsonValue, string, string>

export type JsonArray = JsonValue[]

export type JsonObject = {
  [K in string]?: JsonValue
}

export type JsonPrimitive = boolean | number | string | null

export type JsonValue = JsonArray | JsonObject | JsonPrimitive

export type Timestamp = ColumnType<Date, Date | string, Date | string>

export interface Contracts {
  address: string
  chain_id: Int8
  id: Generated<string>
  name: string
  owner: string
}

export interface Events {
  block_number: Int8
  contract_address: string
  event_name: string
  event_parameters: Json
  id: Generated<string>
  processed: Generated<string>
  timestamp: Timestamp
  transaction_hash: string
}

export interface ListNfts {
  address: string
  chain_id: Int8
  owner: string
  token_id: Int8
}

export interface ListOps {
  address: string
  chain_id: Int8
  code: number
  data: string
  id: Generated<string>
  nonce: Int8
  op: string
  version: number
}

export interface SchemaMigrations {
  version: string
}

export interface DB {
  contracts: Contracts
  events: Events
  list_nfts: ListNfts
  list_ops: ListOps
  schema_migrations: SchemaMigrations
}
