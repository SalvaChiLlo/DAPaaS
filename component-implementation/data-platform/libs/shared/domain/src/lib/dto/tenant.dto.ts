import * as S from '@effect/schema/Schema';
import { BaseDto } from './base.dto';

// Import UserSummaryDto to avoid full UserDto and prevent circular dependencies
export const UserSummaryDto = S.Struct({
  id: S.String,
  name: S.String,
  email: S.String,
});
export type UserSummaryDto = S.Schema.Type<typeof UserSummaryDto>;

export const UserRoles = S.Literal('owner', 'plain')
export type UserRoles = S.Schema.Type<typeof UserRoles>;

export const AddUserDto = S.Struct({ userId: S.String, role: UserRoles })
export type AddUserDto = S.Schema.Type<typeof AddUserDto>;


// Define TenantUserDto with UserSummaryDto
export const TenantUserDto = S.Struct({
  user: UserSummaryDto,
  role: UserRoles,
});
export type TenantUserDto = S.Schema.Type<typeof TenantUserDto>;

// Define the Tenant DTO
export const TenantDto = S.Struct({
  ...BaseDto.fields,
  users: S.optional(S.Array(TenantUserDto)),
  datasets: S.optional(S.Array(S.String)),
  workspaces: S.optional(S.Array(S.String)),
});
export type TenantDto = S.Schema.Type<typeof TenantDto>;

// DTOs for creating and updating tenants
export const CreateTenantDto = TenantDto.pick('id');
export type CreateTenantDto = S.Schema.Type<typeof CreateTenantDto>;

export const UpdateTenantDto = S.partial(CreateTenantDto);
export type UpdateTenantDto = S.Schema.Type<typeof UpdateTenantDto>;
