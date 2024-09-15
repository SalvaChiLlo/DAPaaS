import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { BaseEntity } from './base.entity-schema';
import { UserEntitySchema } from './user.entity-schema';
import { TenantEntitySchema } from './tenant.entity-schema';
import { WorkspaceDto } from '@salvachll/shared/domain';

@Entity()
export class WorkspaceEntitySchema extends BaseEntity implements WorkspaceDto {
  @ManyToOne(() => UserEntitySchema, (user) => user.workspaces, { onDelete: 'CASCADE' })
  createdByUser!: UserEntitySchema;

  @ManyToOne(() => TenantEntitySchema, (tenant) => tenant.workspaces, { onDelete: 'CASCADE' })
  tenant!: TenantEntitySchema;

  // Implementing the DTO properties via getters
  get createdByUserId(): string {
    return this.createdByUser.id;
  }

  get tenantId(): string {
    return this.tenant.id;
  }
}
