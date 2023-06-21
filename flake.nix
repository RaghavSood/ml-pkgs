{
  description = "Provide extra Nix packages for Machine Learning and Data Science";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=ac455609648554cf2fb40d9d1ce030202b0921b7";

    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    overlays = {
      torch-family = import ./overlays/torch-family.nix;
      torch-family-cuda114 = import ./overlays/torch-family-cuda114.nix;
      jax-family = import ./overlays/jax-family.nix;
      data-utils = import ./overlays/data-utils.nix;
      simulators = import ./overlays/simulators.nix;
      math = import ./overlays/math.nix;
      misc = import ./overlays/misc.nix;
      apis = import ./overlays/apis.nix;
      langchain = import ./overlays/langchain.nix;

      # Default is a composition of all above.
      default = nixpkgs.lib.composeManyExtensions [
        self.overlays.torch-family
        self.overlays.jax-family
        self.overlays.data-utils
        self.overlays.simulators
        self.overlays.math
        self.overlays.misc
        self.overlays.apis
        self.overlays.langchain
      ];
    };
  } // inputs.utils.lib.eachSystem [
    "x86_64-linux"
  ] (system:
    let pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            cudaSupport = true;
            # ChatGPT: When you compile a CUDA program, you can specify for
            # which Compute Capability you want to build it. The resulting
            # binary code will be optimized for that specific version of Compute
            # Capability, and it won't run on GPUs with lower Compute
            # Capability. If you want your CUDA program to be able to run on
            # different GPUs, you should compile it for the lowest Compute
            # Capability you intend to support.
            #
            # 7.5 - 20X0 (Ti), T4
            # 8.0 - A100
            # 8.6 - 30X0 (Ti)
            # 8.9 - 40X0 (Ti)
            cudaCapabilities = [ "7.5" "8.6" ];
            cudaForwardCompat = false;
          };
          overlays = [
            self.overlays.default
          ];
        };
    in rec {
      devShells.default = pkgs.callPackage ./pkgs/dev-shell {};
      devShells.isaac = pkgs.callPackage ./pkgs/dev-shell/isaacgym.nix {};

      packages = {
        inherit (pkgs.python3Packages)
          # ----- Torch Family -----
          pytorchWithCuda11
          torchvisionWithCuda11
          pytorchvizWithCuda11
          lightning-utilities
          torchmetricsWithCuda11
          pytorchLightningWithCuda11

          # ----- Jax Family -----
          # jaxWithCuda11
          # equinoxWithCuda11

          # ----- Data Utils -----
          redshift-connector
          # awswrangler  # currently broken

          # ----- Simulators -----
          gym
          gym3
          atari-py-with-rom
          ale-py-with-roms  # currently borken
          procgen
          highway-env
          metadrive-simulator
          robot-descriptions
          mujoco-pybind
          mujoco-menagerie
          dm-tree
          dm-env
          labmaze
          dm-control
          python-fcl

          # ----- Math -----
          numpy-quaternion

          # ----- Misc -----
          numerapi
          huggingface-transformers
          huggingface-accelerate
          huggingface-peft
          bitsandbytes
          tiktoken

          # ----- API -----
          jaraco_context
          wolframalpha
          openai

          # ----- Lang Chain -----
          gptcache
          async-timeout
          openapi-schema-pydantic
          langchain;

        inherit (pkgs) mujoco;
      };

      checks =  {
        full-devshell = self.devShells."${system}".default;
      };
    });
}
