require 'rails_helper'

describe BanxaTopupsCoordinatorJob, type: :job do
  subject { described_class.new }

  describe '.perform' do
    context 'when there is a reward' do
      let!(:reward) { create(:reward, source: 'banxa') }

      it 'uses the reward creation date' do
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 1, start_date: reward.created_at.to_date.to_s,
                end_date: Date.today.to_s)
          .and_return(double(search: []))
        subject.perform
      end
    end

    context 'with no rewards' do
      it 'uses a default date' do
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 1, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: []))
        subject.perform
      end
    end

    context 'without a buy order' do
      let(:top_up) { { order_type: 'CRYPTO-SELL' } }
      it 'does not process the topup' do
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 1, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: [top_up]))
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 2, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: []))

        expect(ProcessTopupJob).to_not receive(:perform_async)
        subject.perform
      end
    end

    context 'with less than 100 USD topup' do
      let(:date) { DateTime.now }
      let(:top_up) do
        { id: 1, order_type: 'CRYPTO-BUY', coin_code: 'USDC', coin_amount: 50,
          completed_at: date.to_s, tx_hash: 'a', wallet_address: '0x1234' }
      end

      it 'process the topup' do
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 1, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: [top_up]))
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 2, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: []))

        expect(ProcessTopupJob).to receive(:perform_async)
          .with(1, '0x1234', date.to_i, 'banxa', 50)
        subject.perform
      end
    end

    context 'when user topups more than 100 USD' do
      let(:date) { DateTime.now }
      let(:top_up) do
        { id: 1, order_type: 'CRYPTO-BUY', coin_code: 'USDC', coin_amount: 100,
          completed_at: date.to_s, tx_hash: 'a', wallet_address: '0x1234' }
      end

      it 'process the topup' do
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 1, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: [top_up]))
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 2, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: []))

        expect(ProcessTopupJob).to receive(:perform_async)
          .with(1, '0x1234', date.to_i, 'banxa', 100)
        subject.perform
      end
    end

    context 'enqueues a new search' do
      let(:date) { DateTime.now }
      let(:top_up) do 
        { order_type: 'CRYPTO-BUY', coin_code: 'USDC', coin_amount: 50, completed_at: date.to_s }
      end

      it 'check the next page' do
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 1, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: [top_up]))
        allow(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 2, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: [top_up]))
        expect(Banxa::Client).to receive(:new)
          .with(limit: 100, page: 3, start_date: '2022-08-18', end_date: Date.today.to_s)
          .and_return(double(search: []))

        subject.perform
      end
    end
  end
end
