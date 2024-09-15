import { Injectable, CanActivate, ExecutionContext, HttpException, HttpStatus, UnauthorizedException } from '@nestjs/common';

@Injectable()
export class RequireAuth implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const requiredHeader = request.headers['authorization'];

    if (!requiredHeader) {
      throw new UnauthorizedException();
    }

    return true;
  }
}
