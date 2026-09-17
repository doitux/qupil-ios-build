# Qupil iOS CI mirror

This repository is managed by build-qupil-ios-v22-from-linux.sh.
The source snapshot comes from the same ./qupil-build-env/source tree used by the Linux/Android v20 build.

The macOS runner installs Qt 6.11.2 for macOS + iOS and creates an unsigned ARM64 iPhone/iPad IPA.
Unsigned IPA files are build artifacts only; installation on a physical iPad requires Apple signing/provisioning or re-signing through a sideloading workflow.
