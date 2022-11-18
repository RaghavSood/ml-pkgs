final: prev: let
  cuda11 = final.cudaPackages_11_8;
in rec {
  python311 = prev.python311.override {
    packageOverrides = pyFinal: pyPrev: rec {
      pyext = pyFinal.callPackage ./pkgs/py311ports/pyext {};
      tensorboard = pyFinal.callPackage ./pkgs/py311ports/tensorboard {};
      
      pytorchWithCuda11 = pyPrev.pytorchWithCuda.override {
        cudaPackages = cuda11;
        magma = final.magmaWithCuda11;
      };

      pytorchLightningWithCuda11 = pyPrev.pytorch-lightning.override {
        torch = pytorchWithCuda11;
      };

      torchvisionWithCuda11 = pyPrev.torchvision.override {
        torch = pytorchWithCuda11;
      };

      pytorchvizWithCuda11 = pyFinal.callPackage ./pkgs/pytorchviz {
        pytorch = pytorchWithCuda11;
      };

      jaxlibWithCuda11 = pyPrev.jaxlibWithCuda.override {
        cudaPackages = cuda11;
      };

      jaxWithCuda11 = pyPrev.jax.override {
        jaxlib = jaxlibWithCuda11;
      };

      equinoxWithCuda11 = pyFinal.callPackage ./pkgs/equinox {
        jax = jaxWithCuda11;
      };

      atari-py-with-rom = pyFinal.callPackage ./pkgs/atari-py-with-rom {};
      ale-py-with-roms = pyFinal.callPackage ./pkgs/ale-py-with-roms {};

      gym-notices = pyFinal.callPackage ./pkgs/gym-notices {};
      gym = pyFinal.callPackage ./pkgs/gym {};
      gym3 = pyFinal.callPackage ./pkgs/gym3 {};

      procgen = pyFinal.callPackage ./pkgs/procgen {};

      redshift-connector = pyFinal.callPackage ./pkgs/redshift-connector {};

      awswrangler = pyFinal.callPackage ./pkgs/awswrangler {};

      numerapi = pyFinal.callPackage ./pkgs/numerapi {};

      highway-env = pyFinal.callPackage ./pkgs/highway-env {};

      panda3d = pyFinal.callPackage ./pkgs/panda3d {};
      panda3d-simplepbr = pyFinal.callPackage ./pkgs/panda3d-simplepbr {};
      panda3d-gltf = pyFinal.callPackage ./pkgs/panda3d-gltf {};

      metadrive-simulator = pyFinal.callPackage ./pkgs/metadrive-simulator {};

      huggingface-transformers = pyFinal.callPackage ./pkgs/huggingface-transformers {
        pytorch = pytorchWithCuda11;
      };

      mujoco = pyFinal.callPackage ./pkgs/mujoco {};

      pytorch-tabnet = pyFinal.callPackage ./pkgs/pytorch-tabnet {
        pytorch = pytorchWithCuda11;
      };

      pybulletx = pyFinal.callPackage ./pkgs/pybulletx {};

      # This package is a shithole of dependency hell. Will revisit.
      #
      # open3d = pyFinal.callPackage ./pkgs/open3d {
      #   cudaPackages = cuda11;
      #   pytorchWithCuda = pytorchWithCuda11;
      # };
    };
  };

  python311Packages = python311.pkgs;

  nvitop = final.callPackage ./pkgs/nvitop {};
  magmaWithCuda11 = prev.magma.override {
    cudaPackages = cuda11;
  };
}
