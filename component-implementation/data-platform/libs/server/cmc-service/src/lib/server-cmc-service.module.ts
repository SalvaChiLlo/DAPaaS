import { Module } from '@nestjs/common';
import { CMCService } from './cmc.service';
import { ServerDataAccessModule } from '@salvachll/server/data-access';
import { HttpModule } from '@nestjs/axios';

@Module({
  controllers: [],
  exports: [CMCService],
  providers: [CMCService],
  imports: [ServerDataAccessModule, HttpModule],

})
export class ServerCmcServiceModule {}
