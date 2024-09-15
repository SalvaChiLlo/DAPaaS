import * as S from '@effect/schema/Schema'


const LocalDBConfig = S.Struct({
  DATABASE_TYPE: S.Literal("sqlite"),
  DATABASE_PATH: S.optional(S.String.pipe(S.nonEmpty()), { default: () => "/tmp/db.sqlite" }),
})

const RemoteDBConfig = S.Struct({
  DATABASE_TYPE: S.Literal("mysql", "mariadb", "postgres"),
  DATABASE_NAME: S.String.pipe(S.nonEmpty()),
  DATABASE_HOST: S.String.pipe(S.nonEmpty()),
  DATABASE_PORT: S.String.pipe(S.nonEmpty()),
  DATABASE_USERNAME: S.String.pipe(S.nonEmpty()),
  DATABASE_PASSWORD: S.String.pipe(S.nonEmpty()),
})


export const Config = S.Union(LocalDBConfig, RemoteDBConfig)

export type Config = S.Schema.Type<typeof Config>

export class BadServerConfig {
  readonly _tag = "BadServerConfig"
  constructor(readonly message: unknown) { }
}