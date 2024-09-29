import os
import glob
from PIL import Image
import numpy as np
import torch

class UltraImageLoader:
    def __init__(self):
        pass

    @classmethod
    def INPUT_TYPES(s):
        return {
            "required": {
                "ImageID": ("INT", {"default": 0, "min": 0, "max": 1000, "step": 1, "display": "number"}),
                "FolderPath": ("STRING", {"default": "", "multiline": False}),
                "RespectSubfolders": (["Off", "On"], {"default": "Off"})
            }
        }

    RETURN_TYPES = ("STRING", "STRING", "IMAGE")
    RETURN_NAMES = ("TotalImages", "ImageFilename", "Image")

    FUNCTION = "load_image"

    CATEGORY = "Image Processing"

    def load_image(self, ImageID, FolderPath, RespectSubfolders):
        # Determine whether to search subfolders
        search_pattern = '**/*.*' if RespectSubfolders == "On" else '*.*'
        image_paths = glob.glob(os.path.join(FolderPath, search_pattern), recursive=(RespectSubfolders == "On"))

        # Filter for supported image formats
        supported_formats = ('.png', '.jpg', '.jpeg', '.bmp', '.tiff', '.gif')
        image_paths = [path for path in image_paths if path.lower().endswith(supported_formats)]

        total_images = len(image_paths)

        if total_images == 0:
            raise ValueError("No images found in the specified directory.")

        if ImageID >= total_images:
            raise IndexError("ImageID exceeds the number of images found.")

        # Select the image based on ImageID
        selected_image_path = image_paths[ImageID]
        image_name = os.path.splitext(os.path.basename(selected_image_path))[0]

        # Load the image
        image = Image.open(selected_image_path).convert('RGB')

        # Convert the image to a tensor suitable for ComfyUI
        image_tensor = torch.from_numpy(np.array(image)).float().div(255).permute(2, 0, 1).unsqueeze(0)

        return str(total_images), image_name, image_tensor

    @classmethod
    def IS_CHANGED(s, ImageID, FolderPath, RespectSubfolders):
        return True

NODE_CLASS_MAPPINGS = {
    "UltraImageLoader": UltraImageLoader
}

NODE_DISPLAY_NAME_MAPPINGS = {
    "UltraImageLoader": "Ultra Image Loader"
}
