# coding: UTF-8
require "spec_helper"
require "dea/bootstrap"

describe Dea do
  include_context "bootstrap_setup"

  before do
    allow(bootstrap).to receive(:setup_directory_server).and_call_original
    allow(bootstrap).to receive(:setup_directory_server_v2).and_call_original
    allow(bootstrap).to receive(:directory_server_v2).and_call_original
  end

  describe "responses to messages received on 'dea.ssh.droplet'" do
    def run
      with_event_machine(:timeout => 1) do
        bootstrap.setup
        bootstrap.start

        @instances =
          [Dea::Instance::State::RUNNING,
           Dea::Instance::State::STOPPED,
           Dea::Instance::State::STARTING].each_with_index.map do |state, ii|
            instance = create_and_register_instance(bootstrap,
                                                    "application_id"      => ((ii == 0) ? 0 : 1).to_s,
                                                    "application_version" => ii,
                                                    "instance_index"      => ii,
                                                    "application_uris"    => ["foo", "bar"])
            instance.state = state
            instance
          end

        fiber = Fiber.new do
          yield
          done
        end

        fiber.resume
      end
    end

    def ssh_droplet(options)
      options[:count] ||= 1

      responses = []

      fiber = Fiber.current
      nats_mock.subscribe("result") do |msg|
        responses << Yajl::Parser.parse(msg)

        if responses.size == options[:count]
          EM.next_tick do
            fiber.resume(responses)
          end
        end
      end

      request = yield
      
      nats_mock.publish("dea.ssh.droplet", request, "result")

      Fiber.yield
    end

    it "should support return ssh details by instance index" do
      responses = []
        
      run do
        first_instance = @instances[0]
        allow(first_instance).to receive(:instance_ssh_port).and_return(1112)
        allow(first_instance).to receive(:instance_ssh_key).and_return("abcdefg")
          
        responses = ssh_droplet(:count => 1) do
          {
            "droplet" => @instances[0].application_id,
            "indices" => [@instances[0].instance_index],
            "states" => [@instances[0].state]
          }
        end
      end

      expect(responses.size).to eq 1
      expect(responses[0]["ip"]).to eq VCAP.local_ip
      expect(responses[0]["sshkey"]).to eq "abcdefg"
      expect(responses[0]["port"]).to eq 1112
      expect(responses[0]["user"]).to eq "vcap"
    end
  end
end
