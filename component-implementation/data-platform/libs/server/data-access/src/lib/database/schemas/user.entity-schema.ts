import { Column, Entity, OneToMany } from 'typeorm';
import { BaseEntity } from './base.entity-schema';
import { TenantUserEntitySchema } from './tenant-user.entity-schema';
import { WorkspaceEntitySchema } from './workspace.entity-schema'; // Import the Workspace entity
import { UserDto } from '@salvachll/shared/domain';

@Entity()
export class UserEntitySchema extends BaseEntity implements UserDto {
  @Column()
  name!: string;

  @Column()
  email!: string;

  // Relationship to TenantUserEntitySchema
  @OneToMany(() => TenantUserEntitySchema, (tenantUser) => tenantUser.user, { eager: true })
  tenantRolesEntities!: TenantUserEntitySchema[];

  // Custom getter to transform tenantRolesEntities to match UserDto structure
  get tenantRoles(): { tenantId: string; role: 'owner' | 'plain' }[] {
    console.log({ tenantRolesEntities: this.tenantRolesEntities })
    return this.tenantRolesEntities.map((tenantUser) => ({
      tenantId: tenantUser.tenantId,
      role: tenantUser.role,
    }));
  }

  // Relationship to WorkspaceEntitySchema
  @OneToMany(() => WorkspaceEntitySchema, (workspace) => workspace.createdByUser, { eager: true })
  workspacesEntities!: WorkspaceEntitySchema[];

  // Custom getter to transform workspacesEntities to match UserDto structure
  get workspaces(): { id: string; tenantId: string }[] {
    return this.workspacesEntities.map((workspace) => ({
      id: workspace.id,
      tenantId: workspace.tenantId,
    }));
  }
}
