require 'rails_helper'
require 'active_support/testing/time_helpers'
#Dummy comment
RSpec.describe OpenaiService do
  include ActiveSupport::Testing::TimeHelpers
  let(:service) { OpenaiService.new }

  describe "Private Helper Methods" do
    before do
      # Direct access to private methods for testing
      @start_time = Time.now
      service.instance_variable_set(:@start_time, @start_time)
      service.instance_variable_set(:@requests_made, 0)
      service.instance_variable_set(:@tokens_used, 0)
    end

    describe "#reset_limits_if_needed" do
      it "resets counters if 60 seconds have passed" do
        # Simulate time passing
        travel_to(@start_time + 61.seconds) do
          service.send(:reset_limits_if_needed)
          expect(service.instance_variable_get(:@requests_made)).to eq(0)
          expect(service.instance_variable_get(:@tokens_used)).to eq(0)
          expect(service.instance_variable_get(:@start_time)).to be_within(1.second).of(Time.now)
        end
      end

      it "does not reset counters if less than 60 seconds have passed" do
        travel_to(@start_time + 59.seconds) do
          service.send(:reset_limits_if_needed)
          expect(service.instance_variable_get(:@requests_made)).to eq(0)
          expect(service.instance_variable_get(:@tokens_used)).to eq(0)
          expect(service.instance_variable_get(:@start_time)).to eq(@start_time)
        end
      end
    end

    describe "#enforce_rate_limits" do
      it "does not sleep if limits are not exceeded" do
        service.instance_variable_set(:@requests_made, 10)
        service.instance_variable_set(:@tokens_used, 2000)
        expect(service).not_to receive(:sleep)
        service.send(:enforce_rate_limits)
      end

      it "sleeps if request limit is exceeded" do
        service.instance_variable_set(:@requests_made, OpenaiService::REQUESTS_PER_MINUTE)
        expect(service).to receive(:sleep).with(be > 0)
        service.send(:enforce_rate_limits)
      end

      it "sleeps if token limit is exceeded" do
        service.instance_variable_set(:@tokens_used, OpenaiService::TOKENS_PER_MINUTE)
        expect(service).to receive(:sleep).with(be > 0)
        service.send(:enforce_rate_limits)
      end

      it "resets limits after sleeping" do
        service.instance_variable_set(:@requests_made, OpenaiService::REQUESTS_PER_MINUTE)
        travel_to(@start_time + 61.seconds) do
          allow(service).to receive(:sleep).and_return(true)
          service.send(:enforce_rate_limits)
          expect(service.instance_variable_get(:@requests_made)).to eq(0)
          expect(service.instance_variable_get(:@tokens_used)).to eq(0)
        end
      end
    end
  end
end
