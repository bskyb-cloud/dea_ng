Vagrant.configure("2") do |config|
  # Build this box by running `rake test_vm`
  config.vm.box = "warden-compatible"
  config.vm.box_url = "https://s3.amazonaws.com/runtime-artifacts/warden-compatible.box"
  config.ssh.username = "vagrant"

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

  config.vm.provision "shell", inline: "sudo apt-get -y update"
  config.vm.provision "shell", inline: "sudo apt-get -q -y install libxslt-dev libxml2-dev" # For Nokogiri
  config.vm.provision "shell", inline: "sudo apt-get -q -y install libcurl4-gnutls-dev" # For
end
