require 'rails_helper'

describe Wyre::RewardClaim do
  let(:wallet) { Faker::Blockchain::Ethereum.address }
  let(:points) { 100 }
  subject { described_class.new(wallet, points) }

  describe '#perform' do
    context 'when there is nothing to claim' do
      it 'does not call the API' do
        expect(RestClient).to_not receive(:post)
        subject.perform
      end
    end

    context 'when the wallet can claim' do
      let(:params) do
        {
          autoConfirm: true,
          source: ENV['WYRE_ACCOUNT_SOURCE'],
          sourceCurrency: "MATIC",
          sourceAmount: 0.0001,
          dest: "matic:#{wallet}"
        }
      end

      let(:headers) do
        {
          Accept: 'application/json',
          Authorization: "Bearer #{ENV['WYRE_API_KEY']}",
          'Content-Type': 'application/json',
        }
      end

      before do
        allow(Reward).to receive(:available_for_claiming?)
          .with(wallet, points).and_return(true)

        allow(RestClient).to receive(:get)
          .and_return(double(body: { 'matic-network' => { usd: 100_000 }}.to_json))
      end

      context 'when the transfer is not complete' do
        it 'returns null' do
          allow(RestClient).to receive(:post)
            .with('https://api.sendwyre.com/v3/transfers', params, headers).
            and_return({})
          expect(subject.perform).to be_nil
        end
      end

      context 'when the transfer is complete' do
        it 'returns the transfer id' do
          allow(RestClient).to receive(:post)
            .with('https://api.sendwyre.com/v3/transfers', params, headers).
            and_return(double(body: { 'transfer' => { id: 'TF_123' }}.to_json))
          expect(subject.perform).to eq('TF_123')
        end
      end

      it 'uses the right params' do
        expect(RestClient).to receive(:post)
          .with('https://api.sendwyre.com/v3/transfers', params, headers).
          and_return(false)
        subject.perform
      end
    end
  end
end
