import { Catch, ArgumentsHost, Logger } from '@nestjs/common';
import { BaseExceptionFilter } from '@nestjs/core';

@Catch()
export class FiberFailureExceptionFilter extends BaseExceptionFilter {

  catch(exception: unknown, host: ArgumentsHost) {
    Logger.error(exception)
    return super.catch(exception, host);
  }
}