# Qupil iOS CI mirror

This repository is an automatically refreshed build mirror.

Source of truth on the developer machine:

    ./qupil-dev

Qupil version:

    1.5.28

Source commit:

    4ec0b1de37f1159f149e8801b08589c8e3d4294c

The Linux launcher is . It uploads only the
committed Git source tree and never modifies .

The macOS runner installs Qt 6.11.2 for macOS + iOS and creates an
unsigned ARM64 iPhone/iPad IPA. Installation on a physical device requires
Apple signing/provisioning or re-signing through the existing sideloading flow.
