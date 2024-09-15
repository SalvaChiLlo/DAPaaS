import * as S from '@effect/schema/Schema';

export const AuthorizationHeader = (S.Struct({
  iss: S.String,
  sub: S.String,
  aud: S.String,
  exp: S.Number,
  iat: S.Number,
  at_hash: S.String,
  email: S.String,
  email_verified: S.Boolean,
  name: S.String,
  federated_claims: S.Struct({
    connector_id: S.String,
    user_id: S.String,
  })
}))
export type AuthorizationHeader = S.Schema.Type<typeof AuthorizationHeader>
