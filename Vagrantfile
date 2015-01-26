Vagrant.configure("2") do |config|

  config.vm.box = "warden-compatible"
  config.vm.box_url = "https://s3.amazonaws.com/runtime-artifacts/warden-compatible.box"

  config.vm.provider :vsphere do |vsphere, override|
    override.vm.box = 'dummy'
    override.vm.box_url = './dummy.box'
    override.vm.network :private_network, ip: ENV['DEA_TEST_VM_IP']
    vsphere.insecure = true
    vsphere.data_center_name = ENV['DEA_VS_DC']
    vsphere.host = ENV['DEA_VS_HOST']
    vsphere.compute_resource_name = ENV['DEA_VS_COMPUTE']
    vsphere.resource_pool_name = ENV['DEA_VS_RES_POOL']
    vsphere.customization_spec_name = ENV['DEA_VS_CUST_SPEC']
    vsphere.template_name = ENV['DEA_VS_TEMPLATE']
    vsphere.name = "dea-integration-tests-#{`hostname`}"
    vsphere.user = ENV['DEA_VS_USER']
    vsphere.password = ENV['DEA_VS_PASS']
  end

  # Requires vagrant-aws and unf plugins
  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    override.ssh.private_key_path = ENV["WARDEN_AWS_PRIVATE_KEY_PATH"]

    aws.ami = ENV["WARDEN_COMPATIBLE_AMI"] || "ami-e0b64188"
    aws.access_key_id = ENV["AWS_ACCESS_KEY_ID"]
    aws.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
    aws.instance_type = "m3.medium"
    aws.tags = { "Name" => "dea-test" }
    aws.block_device_mapping = [{
      :DeviceName => "/dev/sda1", 'Ebs.VolumeSize' => 40
    }]
  end

  # For Nokogiri
  config.vm.provision "shell", inline: "sudo apt-get update"
  config.vm.provision "shell", inline: "sudo apt-get -q -y install libxslt-dev libxml2-dev"
  config.vm.provision "shell", inline: "sudo apt-get -q -y install libcurl4-gnutls-dev"
end
