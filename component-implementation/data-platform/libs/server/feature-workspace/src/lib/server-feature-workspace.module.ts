import { Module } from '@nestjs/common';
import { ServerFeatureWorkspaceController } from './server-feature-workspace.controller';
import { ServerFeatureWorkspaceService } from './server-feature-workspace.service';
import { ServerAuthServiceModule } from '@salvachll/server/auth-service';
import { ServerDataAccessModule } from '@salvachll/server/data-access';
import { ServerUtilsModule } from '@salvachll/server/utils';
import { ServerCmcServiceModule } from '@salvachll/server/cmc-service';

@Module({
  controllers: [ServerFeatureWorkspaceController],
  providers: [ServerFeatureWorkspaceService],
  imports: [ServerDataAccessModule, ServerUtilsModule, ServerAuthServiceModule, ServerCmcServiceModule],
  exports: [ServerFeatureWorkspaceService],
})
export class ServerFeatureWorkspaceModule {}
