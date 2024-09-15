import { Test } from '@nestjs/testing';
import { ServerFeatureTenantService } from './server-feature-tenant.service';

describe('ServerFeatureTenantService', () => {
  let service: ServerFeatureTenantService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [ServerFeatureTenantService],
    }).compile();

    service = module.get(ServerFeatureTenantService);
  });

  it('should be defined', () => {
    expect(service).toBeTruthy();
  });
});
