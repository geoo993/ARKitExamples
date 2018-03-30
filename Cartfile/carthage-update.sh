#!/bin/sh

#  carthage.sh
#  StorySmarties
#
#  Created by Daniel Asher on 29/06/2016.
#  Copyright © 2016 LEXI LABS. All rights reserved.

# Set git to use the osxkeychain credential helper
git config --global credential.helper osxkeychain

carthage update $@ --no-build --no-use-binaries --platform iOS
