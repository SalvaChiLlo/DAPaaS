import * as S from '@effect/schema/Schema';
import { BaseDto } from './base.dto';

export const WorkspaceDto = S.Struct({
  ...BaseDto.fields,
  createdByUserId: S.String, // The user who created the workspace (foreign key reference to User)
  tenantId: S.String, // The tenant that owns the workspace (foreign key reference to Tenant)
});

export type WorkspaceDto = S.Schema.Type<typeof WorkspaceDto>;

export const CreateWorkspaceDto = WorkspaceDto.pick('id', 'tenantId');
export type CreateWorkspaceDto = S.Schema.Type<typeof CreateWorkspaceDto>;

export const UpdateWorkspaceDto = S.partial(CreateWorkspaceDto);
export type UpdateWorkspaceDto = S.Schema.Type<typeof UpdateWorkspaceDto>;
