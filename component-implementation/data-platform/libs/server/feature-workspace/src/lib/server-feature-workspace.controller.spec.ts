import { Test } from '@nestjs/testing';
import { ServerFeatureWorkspaceController } from './server-feature-workspace.controller';
import { ServerFeatureWorkspaceService } from './server-feature-workspace.service';

describe('ServerFeatureWorkspaceController', () => {
  let controller: ServerFeatureWorkspaceController;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [ServerFeatureWorkspaceService],
      controllers: [ServerFeatureWorkspaceController],
    }).compile();

    controller = module.get(ServerFeatureWorkspaceController);
  });

  it('should be defined', () => {
    expect(controller).toBeTruthy();
  });
});
