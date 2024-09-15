import { Module } from '@nestjs/common';
import { DatabaseModule } from './database/database.module';

@Module({
  controllers: [],
  providers: [],
  imports: [DatabaseModule],
  exports: [DatabaseModule],
})
export class ServerDataAccessModule {}
