import { ConflictException, Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { UserDto, UpdateUserDto, AuthorizationHeader } from '@salvachll/shared/domain';
import { Repository } from 'typeorm';
import * as _ from 'lodash';
import { Either } from 'effect';
import { ArrayFormatter } from '@effect/schema';
import * as S from '@effect/schema/Schema';
import { UserEntitySchema } from '@salvachll/server/data-access';

@Injectable()
export class ServerFeatureUserService {

  constructor(
    @InjectRepository(UserEntitySchema)
    private userRepository: Repository<UserDto>
  ) { }

  // Method to list all users
  async listUsers(auth: AuthorizationHeader): Promise<UserDto[]> {
    // Ideally, you'd want to validate the auth token or check permissions here
    return this.userRepository.find();
  }

  // Method to retrieve details of a specific user including tenants, workspaces, and roles
  async getUserDetails(id: string, auth: AuthorizationHeader): Promise<UserDto> {
    const user = await this.userRepository.findOne({
      where: {
        id: id,
      },
      loadEagerRelations: true,
    });

    if (!user) {
      throw new NotFoundException(`User '${id}' not found.`);
    }

    const userObject: UserDto = {
      ...user,
      tenantRoles: user.tenantRoles ?? [],  // Include the result of the getter function
      workspaces: user.workspaces ?? [],    // Include the workspaces getter function result
    };

    const validate = S.validateEither(UserDto)(userObject);
    if (Either.isLeft(validate)) {
      const error = ArrayFormatter.formatErrorSync(validate.left);
      console.error("Decoding failed:", error);
      throw new InternalServerErrorException(error);
    }

    const res = validate.right
    return res;
  }

  // Method to register a new user
  async createUser(auth: AuthorizationHeader): Promise<UserDto> {
    // Check if the user already exists
    const userId = auth.federated_claims.user_id
    const userName = auth.name
    const userEmail = auth.email
    try {
      await this.getUserDetails(auth.federated_claims.user_id, auth);
    } catch (e) {
      // User doesn't exist, so we can proceed with creation
      return this.userRepository.save({ id: userId, name: userName, email: userEmail });
    }

    throw new ConflictException(`User ${auth} already exists`);
  }

  // Method to update an existing user (left here from base example, if needed)
  async update(id: string, data: UpdateUserDto, auth: AuthorizationHeader): Promise<UserDto> {
    const user = await this.getUserDetails(id, auth);
    return this.userRepository.save(_.merge(user, data));
  }

  // Method to delete a user (left here from base example, if needed)
  async delete(id: string, auth: AuthorizationHeader): Promise<void> {
    await this.userRepository.delete({ id });
  }
}
