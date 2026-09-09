#!/bin/sh

cp -a /template/amber-smp/paper-global.yml /amber-smp/config/paper-global.yml
cp -a /template/pumpkin-anarchy/pumpkin.toml /pumpkin-anarchy/pumpkin.toml
cp -a /template/amber-smp/server.properties /amber-smp/server.properties
sed -i "s|VELOCITY_SECRET_REPLACE_ME|$(cat /run/secrets/velocity-secret)|g" /amber-smp/config/paper-global.yml
sed -i "s|VELOCITY_SECRET_REPLACE_ME|$(cat /run/secrets/velocity-secret)|g" /pumpkin-anarchy/pumpkin.toml
sed -i "s|RCON_PASSWORD_REPLACE_ME|$(cat /run/secrets/rcon-password)|g" /amber-smp/server.properties
