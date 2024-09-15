import { Module } from '@nestjs/common';
import { ServerFeatureUserController } from './server-feature-user.controller';
import { ServerFeatureUserService } from './server-feature-user.service';
import { ServerUtilsModule } from '@salvachll/server/utils';
import { ServerAuthServiceModule } from '@salvachll/server/auth-service';
import { ServerDataAccessModule } from '@salvachll/server/data-access';

@Module({
  controllers: [ServerFeatureUserController],
  providers: [ServerFeatureUserService],
  imports: [ServerDataAccessModule, ServerUtilsModule, ServerAuthServiceModule],
  exports: [ServerFeatureUserService],
})
export class ServerFeatureUserModule { }
