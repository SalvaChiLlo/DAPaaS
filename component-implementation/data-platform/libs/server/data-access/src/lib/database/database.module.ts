import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm'
import { UserEntitySchema } from './schemas/user.entity-schema';
import { TenantEntitySchema } from './schemas/tenant.entity-schema';
import { TenantUserEntitySchema } from './schemas/tenant-user.entity-schema';
import { DatasetEntitySchema } from './schemas/dataset.entity-schema';
import { WorkspaceEntitySchema } from './schemas/workspace.entity-schema';

@Module({
  imports: [TypeOrmModule.forFeature([TenantEntitySchema, UserEntitySchema, TenantUserEntitySchema, DatasetEntitySchema, WorkspaceEntitySchema])],
  exports: [TypeOrmModule],
})
export class DatabaseModule { }
