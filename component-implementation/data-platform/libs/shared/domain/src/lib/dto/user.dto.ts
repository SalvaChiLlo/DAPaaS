import * as S from '@effect/schema/Schema';
import { BaseDto } from './base.dto';
import { WorkspaceDto } from './workspace.dto';

// Define the User DTO
export const UserDto = S.Struct({
  ...BaseDto.fields,
  name: S.String.pipe(
    S.minLength(1),
    S.maxLength(50)
  ),
  email: S.String,
  // An array of tenant roles, each with a tenant summary and role
  tenantRoles: S.optional(S.Array(S.Struct({
    tenantId: S.String,
    role: S.Literal('owner', 'plain'),
  }))),
  // An array of workspaces created by the user
  workspaces: S.optional(S.Array(WorkspaceDto.pick('id', 'tenantId'))), // Add workspaces
});
export type UserDto = S.Schema.Type<typeof UserDto>;

// DTOs for creating and updating users
export const CreateUserDto = UserDto.pick('name', 'email');
export type CreateUserDto = S.Schema.Type<typeof CreateUserDto>;

export const UpdateUserDto = S.partial(CreateUserDto);
export type UpdateUserDto = S.Schema.Type<typeof UpdateUserDto>;