import torch

from .e2e import E2E


def get_rmvpe(model_path, device, is_half=True):
    try:
        model = E2E(4, 1, (2, 2))
        state_dict = torch.load(model_path, map_location="cpu", weights_only=True)
        model.load_state_dict(state_dict)
        model.eval()
        if is_half:
            model = model.half()
        else:
            model = model.float()
        model = model.to(device)
        return model
    except Exception as e:
        raise RuntimeError(f"Failed to load RMVPE model: {str(e)}")
