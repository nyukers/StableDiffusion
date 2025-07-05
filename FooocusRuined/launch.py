import os
import sys
import platform
import version
import warnings
from pathlib import Path
import ssl
import argparse

ssl._create_default_https_context = ssl._create_unverified_context

warnings.filterwarnings("ignore", category=FutureWarning, module="insightface")
warnings.filterwarnings("ignore", category=FutureWarning, module="transformers")
warnings.filterwarnings("ignore", category=FutureWarning, module="kornia")
warnings.filterwarnings("ignore", category=UserWarning, module="torchvision")
warnings.filterwarnings("ignore", category=UserWarning, module="gradio")
warnings.filterwarnings("ignore", category=UserWarning, module="torchsde")
warnings.filterwarnings("ignore", category=UserWarning)

warnings.filterwarnings(
    "ignore", category=UserWarning, module="torchvision.transforms.functional_tensor"
)
warnings.filterwarnings(
    "ignore", category=UserWarning, message="TypedStorage is deprecated"
)

from modules.launch_util import (
    is_installed,
    run,
    python,
    run_pip,
    repo_dir,
    requirements_met,
    script_path,
    dir_repos,
)

requirements_file = "requirements_versions.txt"
launch_pip_file = "pip_modules.txt"

git_repos = [
    {
        "name": "ComfyUI",
        "path": "ComfyUI",
        "url": "https://github.com/comfyanonymous/ComfyUI",
        "hash": "5e29e7a488b3f48afc6c4a3cb8ed110976d0ebb8",
        "add_path": "ComfyUI",
    },
    {
        "name": "ComfyUI-GGUF",
        "path": "comfyui_gguf",
        "url": "https://github.com/city96/ComfyUI-GGUF.git",
        "hash": "8d1b56c5e2517219de12a01b742ed53cbaee463e", # Later commits seem to break some gguf models
        "add_path": "",
    },
]

def prepare_environment(offline=False):
    print(f"Python {sys.version}")
    print(f"RuinedFooocus version: {version.version}")

    if offline:
        print("Skip pip check.")
    else:
        run(f'"{python}" -m pip install --upgrade pip', "Check pip", "Couldn't check pip", live=False)
        run(f'"{python}" -m pip install -r "{requirements_file}"', "Check pre-requirements", "Couldn't check pre-reqs", live=False)

    # Remove module if installed from older version
    run(f'"{python}" -m pip uninstall -y flash-attn', "", "", live=False)

    if offline:
        print("Skip check of required modules.")
    else:
        if REINSTALL_ALL or not requirements_met(launch_pip_file):
            print("This next step may take a while")
            os.environ["FLASH_ATTENTION_SKIP_CUDA_BUILD"] = "TRUE"
            run_pip(f'install -r "{launch_pip_file}"', "required modules")

def clone_git_repos(offline=False):
    from modules.launch_util import git_clone

    for repo in git_repos:
        if not offline:
            git_clone(repo["url"], repo_dir(repo["path"]), repo["name"], repo["hash"])
        add_path = str(Path(script_path) / dir_repos / repo["add_path"])
        if add_path not in sys.path:
            sys.path.append(add_path)

def download_models():
    from modules.util import load_file_from_url
    from shared import path_manager

    model_filenames = [
        (
            path_manager.model_paths["modelfile_path"],
            "sd_xl_base_1.0_0.9vae.safetensors",
            "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0_0.9vae.safetensors",
        ),
        (
            path_manager.model_paths["lorafile_path"],
            "sd_xl_offset_example-lora_1.0.safetensors",
            "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_offset_example-lora_1.0.safetensors",
        ),
        (
            path_manager.model_paths["lorafile_path"],
            "lcm-lora-sdxl.safetensors",
            "https://huggingface.co/latent-consistency/lcm-lora-sdxl/resolve/main/pytorch_lora_weights.safetensors",
        ),
        (
            path_manager.model_paths["lorafile_path"],
            "lcm-lora-ssd-1b.safetensors",
            "https://huggingface.co/latent-consistency/lcm-lora-ssd-1b/resolve/main/pytorch_lora_weights.safetensors",
        ),
        (
            path_manager.model_paths["vae_approx_path"],
            "taesdxl_decoder",
            "https://github.com/madebyollin/taesd/raw/main/taesdxl_decoder.pth",
        ),
        (
            "prompt_expansion",
            "pytorch_model.bin",
            "https://huggingface.co/lllyasviel/misc/resolve/main/fooocus_expansion.bin",
        ),
    ]

    for model_dir, file_name, url in model_filenames:
        load_file_from_url(
            url=url,
            model_dir=model_dir,
            file_name=file_name,
        )

from argparser import args

REINSTALL_ALL = False
if os.path.exists("reinstall"):
    REINSTALL_ALL = True

if args.gpu_device_id is not None:
    os.environ['CUDA_VISIBLE_DEVICES'] = str(args.gpu_device_id)
    print("Set device to:", args.gpu_device_id)

offline = os.environ.get("RF_OFFLINE") == "1"

if offline:
    print("Skip checking python modules.")

prepare_environment(offline)

if os.path.exists("reinstall"):
    os.remove("reinstall")

try:
    clone_git_repos(offline)
except:
    print(f"WARNING: Failed checking git-repos. Trying to start without update.")

if not offline:
    download_models()

print("Starting webui")
from webui import *
