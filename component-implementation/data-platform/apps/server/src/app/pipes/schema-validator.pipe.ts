import { ArgumentMetadata, BadRequestException, Injectable, Logger, PipeTransform } from '@nestjs/common';
import * as S from "@effect/schema/Schema"
import { ArrayFormatter } from "@effect/schema"
import { Either } from 'effect';

@Injectable()
export class SchemaValidatorPipe implements PipeTransform {
  transform(value: unknown, metadata: ArgumentMetadata) {
    if (S.isSchema(metadata.metatype)) {
      const validationPipe = S.validateEither(
        metadata.metatype,
        { errors: "all", onExcessProperty: 'ignore' }
      )(value)
      if (Either.isLeft(validationPipe)) {
        const error = ArrayFormatter.formatErrorSync(validationPipe.left)
        Logger.error("Decoding failed:")
        Logger.error(error)
        throw new BadRequestException(error)
      }
      return validationPipe.right;
    }

    return value
  }
}
