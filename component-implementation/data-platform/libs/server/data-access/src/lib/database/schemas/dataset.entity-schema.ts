import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { BaseEntity } from './base.entity-schema';
import { TenantEntitySchema } from './tenant.entity-schema';
import { UserEntitySchema } from './user.entity-schema';
import { DatasetDto } from '@salvachll/shared/domain';

@Entity()
export class DatasetEntitySchema extends BaseEntity implements DatasetDto {
  @Column()
  datasetName!: string;

  @ManyToOne(() => TenantEntitySchema, (tenant) => tenant.datasets, { onDelete: 'CASCADE' })
  tenant!: TenantEntitySchema;

  @ManyToOne(() => UserEntitySchema, { onDelete: 'CASCADE' })
  createdByUser!: UserEntitySchema;

  @Column('jsonb', { nullable: true })
  metadata!: Record<string, string>; // Metadata for the dataset

  // Implementing the `tenantId` and `createdByUserId` as getters
  get tenantId(): string {
    return this.tenant.id; // Accessing the id from the `tenant` relation
  }

  get createdByUserId(): string {
    return this.createdByUser.id; // Accessing the id from the `createdByUser` relation
  }
}
