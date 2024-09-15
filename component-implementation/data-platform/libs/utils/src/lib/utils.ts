
import { BadRequestException, HttpException } from '@nestjs/common'
import * as S from '@effect/schema/Schema'
import { Effect } from 'effect'

export const validatePayload = <T>(payload: unknown, schema: S.Schema<any>): Effect.Effect<T, BadRequestException, never> => S.validate(
  schema,
  {
    errors: "all",
    onExcessProperty: 'ignore',
  }
)(payload).pipe(
  Effect.mapError(e => new BadRequestException(e))
)