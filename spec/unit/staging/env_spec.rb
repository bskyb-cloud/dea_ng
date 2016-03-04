require 'spec_helper'
require 'dea/staging/env'

module Dea::Staging
  describe Env do
    let(:staging_message) { double(:staging_message, mem_limit: 'fake_mem_limit') }
    let(:task) { double('task', staging_config: staging_config, staging_timeout: 'fake_timeout') }
    let(:staging_config) {{}}
    subject(:env) {Env.new(staging_message, task)}

    describe 'system environment variables' do
      subject(:system_environment_variables) { env.system_environment_variables }

      it 'has the correct values' do
        expect(system_environment_variables).to eql([
                                                      %w(STAGING_TIMEOUT fake_timeout),
                                                      %w(MEMORY_LIMIT fake_mem_limitm),
                                                    ])
      end

      context 'staging proxy details' do

        it 'throws error if userinfo is not supplied' do
          staging_config['http_proxy'] = 'http://hem-cs-proxycluster-m-vip-001.stage-paas.bskyb.com:3128'

          expect{env.system_environment_variables}.to raise_error(RuntimeError)
        end

        it 'sets JAVA_OPTS' do
          staging_config['http_proxy'] = 'http://user:password@hem-cs-proxycluster-m-vip-001.stage-paas.bskyb.com:3128'

          expect(env.system_environment_variables).to include ['JAVA_OPTS', '-Dhttp.proxyHost=hem-cs-proxycluster-m-vip-001.stage-paas.bskyb.com -Dhttp.proxyPort=3128 -Dhttp.proxyUser=user -Dhttp.proxyPassword=password']
        end

        it 'sets SBT_OPTS' do
          staging_config['http_proxy'] = 'http://user:password@hem-cs-proxycluster-m-vip-001.stage-paas.bskyb.com:3128'

          expect(env.system_environment_variables).to include ['SBT_OPTS', '-J-Dhttp.proxyHost=hem-cs-proxycluster-m-vip-001.stage-paas.bskyb.com -J-Dhttp.proxyPort=3128 -J-Dhttp.proxyUser=user -J-Dhttp.proxyPassword=password']
        end

      end

    end

    describe 'vcap_application' do
      subject(:vcap_application) { env.vcap_application }
      it 'is empty' do
        expect(vcap_application).to eql({})
      end
    end

    it 'has a message' do
      expect(env.message).to eql(staging_message)
    end

    it 'has an instance' do
      expect(env.staging_task).to eql(task)
    end
  end
end


