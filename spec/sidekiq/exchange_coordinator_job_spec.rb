require 'rails_helper'

describe ExchangeCoordinatorJob, type: :job do
  subject { described_class.new }
  let(:exchange) do
    { 'hash': '0x123', 'destination': '0xabcd', 'timeStamp': '1661252296',
      'symbol': 'USDT', 'txSuccessful': true, 'amount': '100' }
  end
  let(:search) { OpenStruct.new(search: [exchange]) }

  before do
    allow(Zapper::Client).to receive(:new).and_return(search)
  end

  describe '.perform' do
    context 'when a reward is not available' do
      context 'when the transaction was not successful' do
        let(:exchange) do
          { 'hash': '0x123', 'destination': '0xabcd', 'timeStamp': '1661252296',
            'symbol': 'USDT', 'txSuccessful': false, 'amount': '100' }
        end

        it 'does not process the exchange' do
          expect(ProcessTopupJob).to_not receive(:perform_async)
          subject.perform
        end
      end

      context 'when the user did not change to a stablecoin' do
        let(:exchange) do
          { 'hash': '0x123', 'destination': '0xabcd', 'timeStamp': '1661252296',
            'symbol': 'MATIC', 'txSuccessful': false, 'amount': '100' }
        end

        it 'does not process the exchange' do
          expect(ProcessTopupJob).to_not receive(:perform_async)
          subject.perform
        end
      end

      context 'with an already processed exchange' do
        context 'with a previous exchange processed' do
          let!(:reward) { create(:reward, type: 'ExchangeReward', created_at: Time.at(1661252299) )}

          it 'does not process the exchange' do
            expect(ProcessTopupJob).to_not receive(:perform_async)
            subject.perform
          end
        end

        context 'without a previous exchange processed' do
          let(:exchange) do
            { 'hash': '0x123', 'destination': '0xabcd', 'timeStamp': '1661252294',
              'symbol': 'MATIC', 'txSuccessful': false, 'amount': '100' }
          end

          it 'does not process the exchange' do
            expect(ProcessTopupJob).to_not receive(:perform_async)
            subject.perform
          end
        end
      end
    end

    context 'when the reward is available' do
      it 'process the exchange' do
        expect(ProcessTopupJob).to receive(:perform_async)
          .with('0x123', '0xabcd', 1661252296, 'exchange', 100, 'ExchangeReward')
          subject.perform
      end
    end
  end
end
