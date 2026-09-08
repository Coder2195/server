#!/bin/sh

cp /template/amber-smp/paper-global.yml /amber-smp/config/paper-global.yml
cp /template/pumpkin-anarchy/pumpkin.toml /pumpkin-anarchy/pumpkin.toml
sed -i "s|VELOCITY_SECRET_REPLACE_ME|$(cat /run/secrets/velocity-secret)|g" /amber-smp/config/paper-global.yml
sed -i "s|VELOCITY_SECRET_REPLACE_ME|$(cat /run/secrets/velocity-secret)|g" /pumpkin-anarchy/pumpkin.toml
