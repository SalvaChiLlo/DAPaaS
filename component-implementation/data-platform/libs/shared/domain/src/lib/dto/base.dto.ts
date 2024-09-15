import * as S from '@effect/schema/Schema';

export const BaseDto = S.Struct({
  id: S.String.pipe(
    S.minLength(1),
  ),
  createdAt: S.Date,
  updatedAt: S.NullOr(S.Date),
  deletedAt: S.NullOr(S.Date),
})
export type BaseDto = S.Schema.Type<typeof BaseDto>