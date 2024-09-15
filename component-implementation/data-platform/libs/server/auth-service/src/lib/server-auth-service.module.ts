import { Module } from '@nestjs/common';
import { AuthorizationService } from './authorization.service';
import { ServerDataAccessModule } from '@salvachll/server/data-access';

@Module({
  controllers: [],
  providers: [AuthorizationService],
  exports: [AuthorizationService],
  imports: [ServerDataAccessModule],
})
export class ServerAuthServiceModule {}
