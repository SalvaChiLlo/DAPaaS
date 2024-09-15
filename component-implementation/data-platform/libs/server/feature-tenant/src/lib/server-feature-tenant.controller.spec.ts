import { Test } from '@nestjs/testing';
import { ServerFeatureTenantController } from './server-feature-tenant.controller';
import { ServerFeatureTenantService } from './server-feature-tenant.service';

describe('ServerFeatureTenantController', () => {
  let controller: ServerFeatureTenantController;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [ServerFeatureTenantService],
      controllers: [ServerFeatureTenantController],
    }).compile();

    controller = module.get(ServerFeatureTenantController);
  });

  it('should be defined', () => {
    expect(controller).toBeTruthy();
  });
});
