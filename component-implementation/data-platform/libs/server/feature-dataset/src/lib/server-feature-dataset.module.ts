import { Module } from '@nestjs/common';
import { ServerFeatureDatasetController } from './server-feature-dataset.controller';
import { ServerFeatureDatasetService } from './server-feature-dataset.service';
import { ServerAuthServiceModule } from '@salvachll/server/auth-service';
import { ServerDataAccessModule } from '@salvachll/server/data-access';
import { ServerUtilsModule } from '@salvachll/server/utils';

@Module({
  controllers: [ServerFeatureDatasetController],
  providers: [ServerFeatureDatasetService],
  imports: [ServerDataAccessModule, ServerUtilsModule, ServerAuthServiceModule],
  exports: [ServerFeatureDatasetService],
})
export class ServerFeatureDatasetModule {}
