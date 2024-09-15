import { Column, Entity, ManyToOne, PrimaryColumn } from 'typeorm';
import { BaseEntity } from './base.entity-schema';
import { TenantEntitySchema } from './tenant.entity-schema';
import { UserEntitySchema } from './user.entity-schema';
import { TenantUserDto } from '@salvachll/shared/domain';

@Entity()
export class TenantUserEntitySchema implements TenantUserDto {
  @PrimaryColumn()
  tenantId!: string;

  @PrimaryColumn()
  userId!: string;
  
  @ManyToOne(() => TenantEntitySchema, (tenant) => tenant.users)
  tenant!: TenantEntitySchema;

  @ManyToOne(() => UserEntitySchema, (user) => user.tenantRolesEntities)
  user!: UserEntitySchema;

  @Column()
  role!: 'owner' | 'plain'; // Define role as a union type
}
