import { Column, Entity, OneToMany } from 'typeorm';
import { BaseEntity } from './base.entity-schema';
import { TenantUserEntitySchema } from './tenant-user.entity-schema';
import { TenantDto } from '@salvachll/shared/domain';

@Entity()
export class TenantEntitySchema extends BaseEntity implements TenantDto {
  // Relationship to TenantUserEntitySchema
  @OneToMany(() => TenantUserEntitySchema, (tenantUser) => tenantUser.tenant, {
    cascade: true,
    eager: true
  })
  users!: TenantUserEntitySchema[];

  @Column('simple-array', { nullable: true })
  datasets!: string[];

  @Column('simple-array', { nullable: true })
  workspaces!: string[];
}
