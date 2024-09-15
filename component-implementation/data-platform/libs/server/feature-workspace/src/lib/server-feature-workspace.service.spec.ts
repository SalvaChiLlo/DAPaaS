import { Test } from '@nestjs/testing';
import { ServerFeatureWorkspaceService } from './server-feature-workspace.service';

describe('ServerFeatureWorkspaceService', () => {
  let service: ServerFeatureWorkspaceService;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [ServerFeatureWorkspaceService],
    }).compile();

    service = module.get(ServerFeatureWorkspaceService);
  });

  it('should be defined', () => {
    expect(service).toBeTruthy();
  });
});
