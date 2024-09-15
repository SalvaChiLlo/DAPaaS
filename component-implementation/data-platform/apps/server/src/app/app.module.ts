import { Logger, Module } from '@nestjs/common';

import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ServerFeatureUserModule } from '@salvachll/server/feature-user';
import { ServerFeatureTenantModule } from '@salvachll/server/feature-tenant';
import { APP_FILTER } from '@nestjs/core';
import { FiberFailureExceptionFilter } from './exceptionFilter';
import { ConfigModule, ConfigService } from '@nestjs/config'

import { BadServerConfig, Config } from './config';
import { TypeOrmModule } from '@nestjs/typeorm'
import { SchemaValidatorPipe } from './pipes/schema-validator.pipe';
import * as S from "@effect/schema/Schema"
import { Either } from 'effect';
import { ArrayFormatter } from '@effect/schema';
import { ServerUtilsModule } from '@salvachll/server/utils';
import { ServerAuthServiceModule } from '@salvachll/server/auth-service';
import { ServerFeatureDatasetModule } from '@salvachll/server/feature-dataset';
import { ServerFeatureWorkspaceModule } from '@salvachll/server/feature-workspace';
import { ServerCmcServiceModule } from '@salvachll/server/cmc-service';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validate: (config) => {
        const validationPipe = S.validateEither(
          Config, { errors: "all", onExcessProperty: 'ignore' }
        )(config)

        if (Either.isLeft(validationPipe)) {
          const error = ArrayFormatter.formatErrorSync(validationPipe.left)
          console.error("Decoding failed:")
          console.error(error)
          throw new BadServerConfig(error)
        }
        Logger.log("The server has been started with the following configuration: ", validationPipe.right)
        return validationPipe.right;
      }
    }),
    TypeOrmModule.forRootAsync({
      useFactory: (config: ConfigService) => {
        const dbType = config.get<string>('DATABASE_TYPE');

        if (dbType === "sqlite") {
          return {
            type: dbType,
            database: config.get<string>('DATABASE_PATH'),
            synchronize: true,
            logging: true,
            autoLoadEntities: true,
          };
        } else if (dbType === "postgres") {
          return {
            type: 'postgres',
            host: config.get<string>('DATABASE_HOST'),
            port: config.get<number>('DATABASE_PORT'),
            username: config.get<string>('DATABASE_USERNAME'),
            password: config.get<string>('DATABASE_PASSWORD'),
            database: config.get<string>('DATABASE_NAME'),
            synchronize: true,
            logging: true,
            autoLoadEntities: true,
          };
        } else {
          throw new Error(`Unsupported database type: ${dbType}`);
        }
      },
      inject: [ConfigService],
    }),
    ServerFeatureUserModule,
    ServerFeatureTenantModule,
    ServerFeatureDatasetModule,
    ServerFeatureWorkspaceModule,
    ServerUtilsModule,
    ServerAuthServiceModule,
    ServerCmcServiceModule
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_FILTER,
      useClass: FiberFailureExceptionFilter,
    },
    {
      provide: APP_FILTER,
      useClass: SchemaValidatorPipe
    }
  ],
})
export class AppModule { }
