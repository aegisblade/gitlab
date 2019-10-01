# Copyright 2019, Thornbury Organization, Bryan Thornbury
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$script = <<-SCRIPT
echo "172.28.1.1 gitlab.local" >> /etc/hosts

scp /vagrant/data/ssl/gitlab.local-CA.crt /etc/ssl/certs/gitlab.pem
cat /etc/ssl/certs/gitlab.pem >> /etc/ssl/certs/ca-certificates.crt

mkdir -p /etc/docker && echo '{"experimental": true}' | sudo tee /etc/docker/daemon.json
SCRIPT

$startRunner = <<-SCRIPT
runner_number="$1"

docker rm -f gitlab-runner${runner_number}
docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/runner:/etc/gitlab-runner \
  -v /etc/ssl/certs/gitlab.pem:/etc/ssl/certs/gitlab.pem \
  -v /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt \
  --name gitlab-runner${runner_number} \
  --restart=always \
  gitlab/gitlab-runner:latest
SCRIPT

$registerRunner = <<-SCRIPT
runner_number="$1"
registration_token="$2"

docker exec gitlab-runner${runner_number} \
  gitlab-runner register \
    --non-interactive \
    --registration-token ${registration_token} \
    --locked=false \
    --description docker-stable \
    --url https://gitlab.local/ \
    --executor docker \
    --docker-image docker:stable \
    --docker-pull-policy if-not-present \
    --docker-volumes "/var/run/docker.sock:/var/run/docker.sock"

docker exec gitlab-runner${runner_number} \
  sed -i -e 's#concurrent = 1#concurrent = 4#g' /etc/gitlab-runner/config.toml

SCRIPT


Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.network "private_network", ip: "192.168.33.10"

  # Resolve the gitlab.local url properly
  config.vm.provision "shell", inline: $script

  # Install docker & pull the gitlab runner image
  config.vm.provision "docker",
    images: ["gitlab/gitlab-runner"]

  # Start the Gitlab runner
  config.vm.provision "shell" do |s|
    s.inline = $startRunner
    s.args   = "1"
  end

  # Register the Gitlab Runner
  config.vm.provision "shell" do |s|
    s.inline = $registerRunner
    s.args   = "1 #{ENV['TOKEN']}"
  end
end
