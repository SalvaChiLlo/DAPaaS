import { Module } from '@nestjs/common';
import { ServerFeatureTenantController } from './server-feature-tenant.controller';
import { ServerFeatureTenantService } from './server-feature-tenant.service';
import { ServerUtilsModule } from '@salvachll/server/utils';
import { ServerAuthServiceModule } from '@salvachll/server/auth-service';
import { ServerDataAccessModule } from '@salvachll/server/data-access';

@Module({
  controllers: [ServerFeatureTenantController],
  providers: [ServerFeatureTenantService],
  imports: [ServerDataAccessModule, ServerUtilsModule, ServerAuthServiceModule],
  exports: [ServerFeatureTenantService],
})
export class ServerFeatureTenantModule { }
