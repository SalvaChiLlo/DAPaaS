import { Injectable, InternalServerErrorException, NotFoundException, UnauthorizedException } from '@nestjs/common';
import * as S from '@effect/schema/Schema';
import { Either } from 'effect';
import { AuthorizationHeader, UserDto } from '@salvachll/shared/domain';
import { TreeFormatter, ArrayFormatter } from '@effect/schema';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntitySchema } from '@salvachll/server/data-access';
import { Repository } from 'typeorm';

@Injectable()
export class AuthorizationService {
  constructor(
    @InjectRepository(UserEntitySchema)
    private userRepository: Repository<UserDto>
  ) { }

  // Method to decode the authorization header and return the decoded data
  decodeAuthorizationHeader(authHeader: string): AuthorizationHeader {
    try {
      // Extract the token part from the "Bearer <token>" format
      const token = authHeader.split(' ').at(-1) ?? "";

      // Decode the token (Assuming it's a base64-encoded JWT or similar)
      const decoded = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());

      // Validate the structure against the AuthorizationHeader schema
      const validation = S.validateEither(AuthorizationHeader)(decoded);

      if (Either.isLeft(validation)) {
        const errors = ArrayFormatter.formatErrorSync(validation.left);
        throw new UnauthorizedException('Invalid authorization token: ' + errors);
      }

      // Return the decoded and validated authorization header
      return validation.right;
    } catch (err) {
      console.error('Failed to decode authorization header:', err);
      throw new UnauthorizedException('Invalid or malformed authorization header');
    }
  }

  // Method to retrieve the requestor user information from the decoded authorization header
  async getRequestorUser(authHeader: string, validateUserExists = true): Promise<AuthorizationHeader> {
    const auth = this.decodeAuthorizationHeader(authHeader);

    if (!validateUserExists) return auth
    
    const id = auth.federated_claims.user_id

    const user = await this.userRepository.findOne({
      where: {
        id
      },
      // loadRelationIds: true if you're loading related entities by their IDs
    });

    if (!user) {
      throw new UnauthorizedException('User not registered.');
    }

    const validate = S.validateEither(UserDto)(user);
    if (Either.isLeft(validate)) {
      const error = ArrayFormatter.formatErrorSync(validate.left);
      console.error("Decoding failed:", error);
      throw new InternalServerErrorException(error);
    }

    return auth
  }
}
